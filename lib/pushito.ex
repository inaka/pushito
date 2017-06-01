defmodule Pushito do
  use Application
  @moduledoc """
  This is the main module for Pushito. Here there are the functions to connect and push to APNs.
  """

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
  @spec close(atom) :: :ok
  def close(connection_name) do
    Pushito.Connection.close connection_name
  end

end
