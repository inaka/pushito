defmodule Pushito.Supervisor do
  use Supervisor
  @moduledoc """
  This is the Supervisor for pushito. It will create APNs connections on demand.
  """

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = []
    supervise(children, strategy: :one_for_one)
  end

end
