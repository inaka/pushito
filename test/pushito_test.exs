defmodule PushitoTest do
  use ExUnit.Case
  doctest Pushito

  setup_all do
    {:ok, _} = Application.ensure_all_started(:pushito)

    on_exit fn ->
      Application.stop(:pushito)
    end

    :ok
  end

  test "make a connection to APNs with Provider Certificates" do
    connection_name = :connection1
    config = config(connection_name, :cert)

    {:ok, pid} = Pushito.connect(config)

    assert Process.whereis(connection_name) == pid
    assert Pushito.close(connection_name) == :ok
    refute Process.alive?(pid)
  end

  test "Push Notification with Provider Certificate" do
    connection_name = :connection2
    config = config(connection_name, :cert)
    device_id = Application.fetch_env!(:pushito, :device_id)

    {:ok, _pid} = Pushito.connect(config)

    notification =
      %{:aps => %{:alert => "testing push notifications with provider certificate"}}
      |> notification(device_id)

    %Pushito.Response{body: :no_body, headers: _, status: 200} =
      Pushito.push(connection_name, notification)

    assert Pushito.close(connection_name) == :ok
  end

  test "Push Notification with Provider Certificate timeout" do
    connection_name = :connection_timeout
    config = config(connection_name, :cert)
    device_id = Application.fetch_env!(:pushito, :device_id)

    {:ok, _pid} = Pushito.connect(config)

    notification =
      %{:aps => %{:alert => "testing push notifications with provider certificate timeout"}}
      |> notification(device_id)

    assert {:timeout, 1} == Pushito.push(connection_name, %{notification | timeout: 0})
    assert Pushito.close(connection_name) == :ok
  end

  test "Push Notification error, bad device id" do
    connection_name = :connection_bad_wrong_device_id
    config = config(connection_name, :cert)
    device_id = "0"

    {:ok, _pid} = Pushito.connect(config)

    notification =
      %{:aps => %{:alert => "testing push notifications with provider certificate"}}
      |> notification(device_id)

    %Pushito.Response{body: %{"reason" => "BadDeviceToken"}, headers: _, status: 400} =
      Pushito.push(connection_name, notification)
  end

  defp config(connection_name, type) do
    cert_file = Application.fetch_env!(:pushito, :cert_file)
    key_file = Application.fetch_env!(:pushito, :key_file)
    apple_host = Application.fetch_env!(:pushito, :apple_host)

    %Pushito.Config{:name => connection_name,
                    :type => type,
                    :apple_host => apple_host,
                    :cert_file => cert_file,
                    :key_file => key_file}
  end

  defp notification(message, device_id) do
    apns_topic = Application.fetch_env!(:pushito, :apns_topic)

    %Pushito.Notification{:device_id => device_id, :apns_topic => apns_topic, :message => message}
  end
end
