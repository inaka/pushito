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

  ## Client applications

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
  @spec push(connection_name, Pushito.Notification.t) :: Pushito.Response.t
  def push(connection_name, notification) do
    Pushito.Connection.push(connection_name, notification)
  end

end
