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
end
