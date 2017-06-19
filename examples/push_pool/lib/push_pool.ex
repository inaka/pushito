defmodule PushPool do
  use Application

  @pool_name :pushito_pool

  def start(_type, _args) do
    PushPool.Supervisor.start_link @pool_name
  end

  def push(%Pushito.Notification{} = notification) do
    :poolboy.transaction(@pool_name, &PushPool.Worker.push(&1, notification))
  end

  def notification(message, device_id) do
    import Pushito.Notification

    apns_topic = Application.fetch_env!(:pushito, :apns_topic)

    body =  %{"aps" =>
               %{"alert" => message,
                 "sound" => "default",
                 "badge" => 1}
             }

    new()
    |> add_device_id(device_id)
    |> add_topic(apns_topic)
    |> add_message(body)
  end
end
