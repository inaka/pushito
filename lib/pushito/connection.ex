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

end
