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

  test "make a connection to APNs without connection name" do
    config = config(nil, :cert)

    {:ok, pid} = Pushito.connect(config)

    assert Pushito.close(pid) == :ok
    refute Process.alive?(pid)
  end

  test "Push Notification without connection name" do
    config = config(nil, :cert)
    device_id = Application.fetch_env!(:pushito, :device_id)

    {:ok, pid} = Pushito.connect(config)

    notification =
      %{:aps => %{:alert => "testing push notifications without connection name"}}
      |> notification(device_id)

    %Pushito.Response{body: :no_body, headers: _, status: 200} =
      Pushito.push(pid, notification)

    assert Pushito.close(pid) == :ok
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

    assert Pushito.close(connection_name) == :ok
  end

  test "Push Notification with Token" do
    connection_name = :connection_token
    config = config(connection_name, :token)

    {:ok, _pid} = Pushito.connect(config)

    token = Pushito.generate_token(connection_name)
    device_id = Application.fetch_env!(:pushito, :device_id)

    notification =
      %{:aps => %{:alert => "testing push notifications with token"}}
      |> notification(device_id)
      |> Pushito.Notification.add_token(token)

    %Pushito.Response{body: :no_body, headers: _, status: 200} =
      Pushito.push(connection_name, notification)

    assert Pushito.close(connection_name) == :ok
  end

  test "Retrieve the config from the GenServer" do
    connection_name = :get_config_connection
    config = config(connection_name, :cert)

    {:ok, _pid} = Pushito.connect(config)

    assert config == Pushito.Connection.get_config(connection_name)
    assert Pushito.close(connection_name) == :ok
  end

  test "Retrieve the config from the GenServer without connection_name" do
    config = config(nil, :cert)

    {:ok, pid} = Pushito.connect(config)

    assert config == Pushito.Connection.get_config(pid)
    assert Pushito.close(pid) == :ok
  end

  test "Generate Token" do
    connection_name = :connection_token2
    config = config(connection_name, :token)

    {:ok, pid} = Pushito.connect(config)

    _token = Pushito.generate_token(connection_name)
    _token2 = Pushito.generate_token(pid)

    assert Pushito.close(connection_name) == :ok
  end

  test "Backoff strategy if http/2 connection goes down" do
    connection_name = :get_backoff_connection
    config = config(connection_name, :cert)

    {:ok, connection_pid} = Pushito.connect(config)

    h2_connection = Pushito.Connection.get_h2_connection connection_name

    assert Process.alive?(connection_pid)
    assert Process.alive?(h2_connection)

    Process.exit(h2_connection, :reason)

    assert Process.alive?(connection_pid)
    refute Process.alive?(h2_connection)
    assert_receive {:reconnecting, ^connection_pid}, 5000
    assert_receive {:connection_up, ^connection_pid}, 5000

    h2_connection2 = Pushito.Connection.get_h2_connection connection_name

    refute h2_connection == h2_connection2

    assert Pushito.close(connection_name) == :ok
  end

  test "Restrict calls to push for connection's opener" do
    alias Pushito.Notification

    config = config(nil, :cert)
    test_pid = self()

    spawned_pid = spawn fn ->
      {:ok, pid} = Pushito.connect(config)

      send test_pid, {self(), pid}
    end

    connection_pid =
      receive do
        {^spawned_pid, pid} -> pid
      end

    device_id = Application.fetch_env!(:pushito, :device_id)

    notification =
      %{:aps => %{:alert => "testing push notifications"}}
      |> notification(device_id)
      |> Notification.add_timeout(1)

    {:error, :not_connection_owner} = Pushito.push(connection_pid, notification)

    assert Pushito.close(connection_pid) == :ok
  end

  defp config(connection_name, type) do
    import Pushito.Config

    cert_file = Application.fetch_env!(:pushito, :cert_file)
    key_file = Application.fetch_env!(:pushito, :key_file)
    apple_host = Application.fetch_env!(:pushito, :apple_host)
    token_key_file = Application.fetch_env!(:pushito, :token_key_file)
    token_key_id = Application.fetch_env!(:pushito, :token_key_id)
    team_id = Application.fetch_env!(:pushito, :team_id)

    new()
    |> add_name(connection_name)
    |> add_type(type)
    |> add_host(apple_host)
    |> add_cert_file(cert_file)
    |> add_key_file(key_file)
    |> add_token_key_file(token_key_file)
    |> add_token_key_id(token_key_id)
    |> add_team_id(team_id)
  end

  defp notification(message, device_id) do
    import Pushito.Notification

    apns_topic = Application.fetch_env!(:pushito, :apns_topic)

    new()
    |> add_device_id(device_id)
    |> add_topic(apns_topic)
    |> add_message(message)
  end
end
