defmodule PushPool.Worker do
  use GenServer

  def start_link(%Pushito.Config{} = config) do
    GenServer.start_link(__MODULE__, config)
  end

  def push(worker_id, %Pushito.Notification{} = notification) do
    GenServer.call(worker_id, {:push, notification})
  end

  ## GenServer Callbacks

  def init(%Pushito.Config{} = config) do
    {:ok, connection_pid} = Pushito.connect(config)
    {:ok, %{:connection_pid => connection_pid}}
  end

  def handle_call({:push, notification}, _from, %{:connection_pid => connection_pid} = state) do
    response = Pushito.push(connection_pid, notification)

    {:reply, response, state}
  end

end
