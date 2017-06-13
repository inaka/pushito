defmodule Pushito do
  use Application

  @moduledoc ~s"""
  Pushito is an APNs library over the HTTP/2 API. This is the Main module and the one you should use in your applications.

  ## Connect to APNs

  In order to create connections we will use `Pushito.connect/1` function. It only has one argument which is the config information. The `config` is a `Pushito.Config` struct and its format is:

  ```elixir
  defstruct type: :cert,
            name: nil,
            apple_host: nil,
            cert_file: nil,
            key_file: nil,
            token_key_file: nil,
            token_key_id: nil,
            team_id: nil
  ```

  `Pushito.Config` provides setters in order to set the properties.

  There are two types of connection with APNs, `cert` and `token`. The first one is with `Provider Certificate` and the second one is with `Provider Authentication Tokens`. Depending the type you should fill some properties in the `config` structure.

  - For `Provider Certificate` type Apple gives us a `cer` file. We need to convert it to 2 `pem` files, you can check [here](convert-cer-to-pem.html) how to do it
  - For `Provider Authentication Token` Apple gives us a `.p8` file. It is fine, no conversion is needed.

  ### Mandatory Properties for both types
  - `type`: can be `:cert` or `:token`, default value is `:cert`
  - `apple_host`: the Apple host. Currently only `api.development.push.apple.com` or `api.push.apple.com` are available.

  ```elixir
  import Pushito.Config

  config = new()
           |> add_type(:cert)
           |> add_host("api.development.push.apple.com")
  ```

  ### Optional Properties for both types
  - `name`: this is the name of the connection, it must be an `:atom`. If this property is set we
  could refer the connection by this name

  ```elixir
  config
  |> add_name(:my_first_connection)
  ```

  ### Mandatory Properties for `Provider Certificate` type
  - `cert_file`: path to your certification file.
  - `key_file`: path to key file

  ```elixir
  config
  |> add_cert_file("priv/cert2.pem")
  |> add_key_file("priv/key2-noenc.pem")
  ```

  ### Mandatory Properties for `Provider Authentication Tokens` type
  - `token_key_file` is the path to the token key file provided by Apple
  - `token_key_id` is the key id provided by Apple
  - `team_id` is your team developer id

  ```elixir
  config
  |> add_token_key_file("priv/APNsAuthKey_1234567890.p8")
  |> add_token_key_id("1234567890")
  |> add_team_id("THEATEAM")
  ```

  ### Connect
  Once we have the `config` structure we can connect to APNs using `Pushito.connect/1`

  ```elixir
  {:ok, connection_pid} = Pushito.connect(config)
  ```
  `connection_pid` is the connection pid. It is needed if the connection has no name, you must refer the connection with the `connection_pid`

  ## Push Notifications

  **Important** The process which calls `Pushito.connect/1` should be the same as the one which calls `Pushito.push/2`

  Once we have the connection done we can start pushing messages to APNs.
  In order to do that we will use `Pushito.push/2`. The first argument is the connection_name or the connection pid and the second one is the notification itself.
  The notification is a `Pushito.Notification` structure with the format:

  ```elixir
  defstruct device_id: nil,
            apns_expiration: 0,
            apns_priority: 10,
            apns_topic: nil,
            apns_id: nil,
            apns_collapse_id: nil,
            token: nil,
            timeout: 10,
            message: %{}
  ```
  Depending the connection type there are some mandatory properties to fill.

  ### Mandatory Properties for both types
  - `device_id`: the device id we want to send the message
  - `apns_topic`: the topic identifying your App
  - `message`: the message we want to send

  ```elixir
  import Pushito.Notification

  notification = new()
                 |> add_device_id("bd5c3ad01bbe4d884bf2fe8801ed77e94a71bc2e9de937c84f745f54eb4cb2f4")
                 |> add_topic("com.inaka.myapp")
                 |> add_message(%{:aps => %{:alert => "you have a message!!"}})
  ```

  ### Mandatory Properties for `Provider Authentication Tokens` type
  - `token`: The JWT token needed for push notifications with tokens. In order to get a token we have to call `Pushito.generate_token/1` where the argument is the `connection_name` or the connection id.

  ```elixir
  token = Pushito.generate_token(:my_token_connection)

  notification
  |> add_token(token)
  ```

  ### Optional Properties for both types
  - `timeout`: the seconds util throw a timeout. If you get a timeout it means you exceed the time but maybe your notification was sent correctly. Default value is 10 seconds

  Those are the remaining apns fields. You can check them [here](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CommunicatingwithAPNs.html#//apple_ref/doc/uid/TP40008194-CH11-SW1)
  - `apns_expiration`: default value is 0
  - `apns_priority`: default value is 10
  - `apns_id`: can be ignored. APNs will assign one and add it to the response
  - `apns_collapse_id`

  ```elixir
  notification
  |> add_timeout(20)
  |> add_expiration(0)
  |> add_priority(10)
  |> add_id("ID")
  |> add_collapse_id("collapse_id")
  ```

  ### Response
  If you don't get a `timeout` after pushing a message you must receive a response. Every request to APNs servers returns a Response.

  The Responses are `Pushito.Response` struct with the format:

  ```elixir
  defstruct status: nil, headers: [], body: :no_body
  ```
  - status: is the http2 result code. You can check the [HTTP/2 Response from APN](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CommunicatingwithAPNs.html#//apple_ref/doc/uid/TP40008194-CH11-SW1) section
  - headers: is a list with the response headers
  - body: is a list with the body or `:no_body` when no body is returned

  ### Timeout
  If the call to `Pushito.push/2` returns a `{:timeout, stream_id}` it means your process exceeded the timeout time waiting for a response from APNs. That could be caused because your `timeout` should be greater, because the network went down or maybe other causes.

  If you get a timeout it doesn't mean your notification wasn't delivered correctly for sure.
  If the network went down `chatterbox` (the HTTP/2 client `pushito` relies) will try to connect again and it will send the message when the network goes up.
  If that is the case the caller process will receive a message on its mail box with the format `{:apns_response, connection_pid, stream_id, response}` where the `connection_pid` is the connection pid (same as `Process.whereis(connection_name)`) and the `stream_id` is the notification identifier returned in the timeout tuple.

  ## Reconnections

  If something unexpected happens and the `chatterbox` connection with APNs crashes `pushito` will send a message `{:reconnecting, connection_pid}` to the client process, that means `pushito` lost the connection and it is trying to reconnect. Once the connection has been recover a `{:connection_up, connection_pid}` message will be send.

  We implemented an Exponential Backoff strategy.

  ## Closing Connections

  Apple recommends us to keep our connections open and avoid opening and closing very often. You can check the [Best Practices for Managing Connections](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CommunicatingwithAPNs.html).

  But when closing a connection makes sense `pushito` gives us the function `Pushito.close/1` where the parameter is the connection's name or pid. After closing a connection the name will be available for new connections again.
  """

  @type connection_name :: atom

  @doc """
  Application callback for starting Pushito.
  """
  def start(_type, _args) do
    Pushito.Supervisor.start_link
  end

  ## Client API

  @doc """
  Creates a connection with APNs

  ## Example

  We need a valid `Pushito.Config` structure, you can see above how to create it:

      {:ok, connection_pid} = Pushito.connect config
      {:ok, #PID<0.233.0>}

  """
  @spec connect(Pushito.Config.t) :: {:ok, pid}
  def connect(config) do
    Pushito.Supervisor.start_connection(config, self())
  end

  @doc """
  Closes a connection by connection name or connection pid

  ## Example

  It will close the given connection name

      Pushito.close :my_connection
      :ok

  """
  @spec close(connection_name | pid) :: :ok
  def close(connection) do
    Pushito.Connection.close connection
  end

  @doc """
  Push notification to APNs with Provider Certificate

  ## Example

  We need a valid `Pushito.Notification` struct before push something, you can see above how to create it.
  The first paramente can be the connection name (if the connection has a name) or the connection pid.

      Pushito.push :my_connection, notification
      %Pushito.Response{body: :no_body,
       headers: [{"apns-id", "34F4B4F4-ADB6-982F-EB23-36632837520C"}], status: 200}

  That was a succesfull request but it can return errors or timeout, lets force a timeout:

      notification = notification |> Pushito.Notification.add_timeout(0)
      :ok

      Pushito.push :my_connection, notification
      {:timeout, 3}

  But it only means the time exceeded the timeout, we can see in the process mailbox if it worked:

      flush()
      {:apns_response, #PID<0.250.0>, 3,
       %Pushito.Response{body: :no_body,
        headers: [{"apns-id", "AA2C383F-2222-DC0B-B4B8-BA2E8A4F46F4"}], status: 200}}
      :ok

  """
  @spec push(connection_name | pid, Pushito.Notification.t) ::
    Pushito.Response.t | {:timeout, integer}
  def push(connection, notification) do
    Pushito.Connection.push(connection, notification)
  end

  @doc """
  Generates a JWT token in order to push notifications.

  This only makes sense when the connection type is `token`. The lifetime of each token will be 1 hour then it will expire

  ## Example

  In order to create the token, we must be added the mandatory fields for `token` type connections:

      config
      |> add_token_key_file("priv/APNsAuthKey_1234567890.p8")
      |> add_token_key_id("1234567890")
      |> add_team_id("THEATEAM")

  Then we can create the token with the connection name or the connection pid as an argument:

      token = Pushito.generate_token :my_connection
      "eyJhbGciOiJFUzI1NiIsImtpZCI6IjEyMzQ1Njc4OTAiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjE0OTY5NDI1NzgsImlhdCI6MTQ5NjkzNTM3OCwiaXNzIjoiVEhFQVRFQU0iLCJuYmYiOjE0OTY5MzUzNzd9.5dCjXP-JTsJaGND9MqBEnWkzBb2-Wya1wv9I0p8ljQTtdybl6Vnc3H5St88HEFMLOrFzUMhrbMy04Pg42sshMQ"

  """
  @spec generate_token(connection_name | pid) :: String.t
  def generate_token(connection) do
    import Joken

    config = Pushito.Connection.get_config(connection)

    key = JOSE.JWK.from_pem_file(config.token_key_file)

    token()
    |> with_claims(%{"iss" => config.team_id, "iat" => :os.system_time(:seconds)})
    |> with_header_arg("alg", "ES256")
    |> with_header_arg("typ", "JWT")
    |> with_header_arg("kid", config.token_key_id)
    |> sign(es256(key))
    |> get_compact
  end

end
