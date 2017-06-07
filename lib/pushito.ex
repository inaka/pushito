defmodule Pushito do
  use Application

  @moduledoc """
  This is the main module for Pushito. Here there are the functions to connect and push to APNs.
  """

  @type connection_name :: atom

  @doc """
  Application callback for starting Pushito.
  """
  def start(_type, _args) do
    Pushito.Supervisor.start_link
  end

  ## Client API

  @doc """
  Creates a connection with APNs
  """
  @spec connect(Pushito.Config.t) :: {:ok, pid}
  def connect(config) do
    Pushito.Supervisor.start_connection(config, self())
  end

  @doc """
  Closes a connection by name
  """
  @spec close(connection_name) :: :ok
  def close(connection_name) do
    Pushito.Connection.close connection_name
  end

  @doc """
  Push notification to APNs with Provider Certificate
  """
  @spec push(connection_name, Pushito.Notification.t) :: Pushito.Response.t {:timeout, integer}
  def push(connection_name, notification) do
    Pushito.Connection.push(connection_name, notification)
  end

  @doc """
  Generates a JWT token in order to push notifications.
  """
  @spec generate_token(connection_name) :: String.t
  def generate_token(connection_name) do
    import Joken

    config = Pushito.Connection.get_config(connection_name)

    key = JOSE.JWK.from_pem_file(config.token_key_file)

    token()
    |> with_claims(%{"iss" => config.team_id, "iat" => :os.system_time(:seconds)})
    |> with_header_arg("alg", "ES256")
    |> with_header_arg("typ", "JWT")
    |> with_header_arg("kid", config.token_key_id)
    |> sign(es256(key))
    |> get_compact
  end

end
