defmodule Pushito.Connection do
  use GenServer
  @moduledoc """
  This GenServer represents the APNs Connection.
  """

  alias Pushito.Connection.State
  alias Pushito.Config

  ## Client API

  @doc """
  Starts the connection.
  """
  @spec start_link(Config.t, pid) :: {:ok, pid}
  def start_link(config, client) do
    GenServer.start_link(__MODULE__, {config, client}, name: config.name)
  end


  @spec push(Pushito.connection_name, Pushito.Notification.t) :: Pushito.Response.t
  def push(connection_name, notification) do
    stream_id = GenServer.call connection_name, {:push, notification}

    wait_response(connection_name, stream_id, notification.timeout)
  end

  @doc """
  Closes a connection by name.
  """
  @spec close(atom) :: :ok
  def close(connection_name) do
    GenServer.call connection_name, :stop
  end

  ## GenServer Callbacks

  def init({config, client}) do
    {:ok, h2_connection} = h2_connection(config)
    {:ok, %State{:config => config, :client => client, :h2_connection => h2_connection}}
  end

  def handle_call(:stop, _from, state) do
    {:stop, :normal, :ok, state}
  end
  def handle_call({:push, notification}, _from, state) do
    headers = get_headers(state.config, notification)
    {:ok, message} = Poison.encode(notification.message)

    {:ok, stream_id} = :h2_client.send_request(state.h2_connection, headers, message)

    {:reply, stream_id, state}
  end

  def handle_info({:END_STREAM, stream_id}, state) do
    {:ok, {resp_headers, resp_body}} = :h2_client.get_response(state.h2_connection, stream_id)

    status = get_status(resp_headers)
    response_headers_normalized = normalize_response_headers(resp_headers)
    response_body_normalized = normalize_response_body(resp_body)

    response = %Pushito.Response{:status => status,
                                 :headers => response_headers_normalized,
                                 :body => response_body_normalized}

    send state.client, {:apns_response, self(), stream_id, response}

    {:noreply, state}
  end

  ## Private functions

  defp h2_connection(config) do
    :h2_client.start_link(:https, config.apple_host |> to_charlist, config |> transport_options)
  end

  defp transport_options(%Config{type: :cert} = config) do
    [certfile: to_charlist(config.cert_file), keyfile: to_charlist(config.key_file)]
  end
  defp transport_options(%Config{type: :token}) do
    []
  end

  defp get_headers(config, notification) do
    [{":method", "POST"},
     {":path", "/3/device/" <> notification.device_id},
     {":scheme", "https"},
     {":authority", config.apple_host <> ":443"},
     {"apns-expiration", to_string(notification.apns_expiration)},
     {"apns-priority", to_string(notification.apns_priority)},
     {"apns-topic", notification.apns_topic}]
     |> add_apns_id(notification.apns_id)
     |> add_apns_collapse_id(notification.apns_collapse_id)
     |> add_authorization(config.type, notification.token)
  end

  defp add_apns_id(headers, nil) do
    headers
  end
  defp add_apns_id(headers, apns_id) do
    [{"apns-id", apns_id} | headers]
  end

  defp add_apns_collapse_id(headers, nil) do
    headers
  end
  defp add_apns_collapse_id(headers, apns_collapse_id) do
    [{"apns-collapse-id", apns_collapse_id} | headers]
  end

  defp add_authorization(headers, :cert, _) do
    headers
  end
  defp add_authorization(headers, :token, token) do
    [{"authorization", "bearer " <> token} | headers]
  end

  defp get_status(response_headers) do
    {":status", status} = List.keyfind(response_headers, ":status", 0)
    {status_code, _} = Integer.parse(status)
    status_code
  end

  defp normalize_response_headers(response_headers) do
    List.keydelete(response_headers, ":status", 0)
  end

  defp normalize_response_body([]) do
    :no_body
  end
  defp normalize_response_body(response_body) do
    {:ok, response_body_decoded} = Poison.decode(response_body)
    response_body_decoded
  end

  defp wait_response(connection_name, stream_id, timeout) do
    connection_pid = Process.whereis(connection_name)
    timeout_millis = timeout * 1000

    receive do
      {:apns_response, ^connection_pid, ^stream_id, response} -> response
    after
      timeout_millis -> {:timeout, stream_id}
    end
  end

end
