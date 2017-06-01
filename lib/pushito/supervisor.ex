defmodule Pushito.Supervisor do
  use Supervisor
  @moduledoc """
  This is the Supervisor for pushito. It will create APNs connections on demand.
  """

  @doc """
  Starts the supervisor for pushito.
  """
  @spec start_link() :: {:ok, pid}
  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Starts a new connection with APNs. A valid Config should be passed.
  """
  @spec start_connection(Pushito.Config.t, pid) :: {:ok, pid}
  def start_connection(config, client) do
    Supervisor.start_child(__MODULE__, [config, client])
  end

  ## Supervisor Callbacks

  def init(:ok) do
    children = [worker(Pushito.Connection, [], restart: :temporary)]
    supervise(children, strategy: :simple_one_for_one)
  end

end
