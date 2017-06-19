defmodule PushPool.Supervisor do
  use Supervisor

  def start_link(pool_name) do
    Supervisor.start_link(__MODULE__, pool_name, name: __MODULE__)
  end


  ## Supervisor Callbacks

  def init(pool_name) do
    pool_args = [{:name, {:local, pool_name}},
                 {:worker_module, PushPool.Worker},
                 {:size, 10},
                 {:max_overflow, 20}]

    [:poolboy.child_spec(pool_name, pool_args, config())]
    |> supervise(strategy: :one_for_one)
  end

  ## Private functions

  defp config() do
    import Pushito.Config

    cert_file = Application.fetch_env!(:pushito, :cert_file)
    key_file = Application.fetch_env!(:pushito, :key_file)
    apple_host = Application.fetch_env!(:pushito, :apple_host)

    new()
    |> add_type(:cert)
    |> add_host(apple_host)
    |> add_cert_file(cert_file)
    |> add_key_file(key_file)
  end

end
