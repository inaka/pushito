defmodule Pusher do
  @moduledoc """
  Documentation for Pusher.
  """

  def create_connection do
    import Pushito.Config

    config = new()
             |> add_name(:knuff_connection)
             |> add_type(:cert)
             |> add_host("api.push.apple.com")
             |> add_cert_file("priv/apns-cert.pem")
             |> add_key_file("priv/apns-key-noenc.pem")

    {:ok, _pid} = Pushito.connect config
    :ok
  end

  def push(message) do
    import Pushito.Notification

    apns_topic = "com.madebybowtie.Knuff-iOS"
    device_id = "bd5c3ad01bbe4d884bf2fe8801ed77e94a71bc2e9de937c84f745f54eb4cb2f3"

    body = %{"aps" =>
              %{"alert" => message,
                "sound" => "default",
                "badge" => 1}
            }

    notification = new()
                   |> add_device_id(device_id)
                   |> add_topic(apns_topic)
                   |> add_message(body)

    Pushito.push :knuff_connection, notification
  end
end
