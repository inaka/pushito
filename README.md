# pushito
APNS over HTTP/2 for Elixir. Inspired on Erlang the project [apns4erl](https://github.com/inaka/apns4erl)

Copyright (c) 2017 Erlang Solutions Ltd. <support@inaka.net>, released under the Apache 2 license

**note** this project is under development

## Contact Us
For **questions** or **general comments** regarding the use of `Pushito`, please use our public
[hipchat room](http://inaka.net/hipchat).

If you find any **bugs** or have a **problem** while using `Pushito`, please [open an issue](https://github.com/inaka/pushito/issues/new) in this repo (or a pull request :)).

And you can check all of our open-source projects at [inaka.github.io](http://inaka.github.io)

## Connect to APNs

In order to create connections we will use `Pushito.connect/1` function. It only has one argument which is the config information. The `config` is a `Pushito.Config` struct and this format is:

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

##### Mandatory Properties for both types
- `type`: can be `:cert` or `:token`, default value is `:cert`
- `name`: this is the name of the connection, it must be an `:atom`
- `apple_host`: the Apple host. Currently only `api.development.push.apple.com` or `api.push.apple.com` are available.

```elixir
import Pushito.Config

config = new()
         |> add_name(:my_first_connection)
         |> add_type(:cert)
         |> add_host("api.development.push.apple.com")
```

##### Mandatory Properties for `Provider Certificate` type
- `cert_file`: path to your certification file.
- `key_file`: path to key file

```elixir
config
|> add_cert_file("priv/cert2.pem")
|> add_key_file("priv/key2-noenc.pem")
```

##### Mandatory Properties for `Provider Authentication Tokens` type
- `token_key_file` is the path to the token key file provided by Apple
- `token_key_id` is the key id provided by Apple
- `team_id` is your team developer id

```elixir
config
|> add_token_key_file("priv/APNsAuthKey_1234567890.p8")
|> add_token_key_id("1234567890")
|> add_team_id("THEATEAM")
```

##### Connect
Once we have the `config` structure we can connect to APNs using `Pushito.connect/1`

```elixir
{:ok, connection_pid} = Pushito.connect(config)
```
`connection_pid` is the connection pid. It is only needed if we want to supervise it directly.

## Push Notifications
Once we have the connection done we can start pushing messages to APNs.
In order to do that we will use `Pushito.push/2`. The first argument is the connection_name and the second one is the notification itself. The notification is a `Pushito.Notification` structure with the format:

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

##### Mandatory Properties for both types
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

##### Mandatory Properties for `Provider Authentication Tokens` type
- `token`: The JWT token needed for push notifications with tokens. In order to get a token we have to call `Pushito.generate_token/1` where the argument is the `connection_name`

```elixir
token = Pushito.generate_token(:my_token_connection)

notification
|> add_token(token)
```

##### Optional Properties for both
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

##### Response
If you don't get a `timeout` after pushing a message you must receive a response. Every request to APNs servers returns a Response.

The Responses are `Pushito.Response` struct with the format:

```elixir
defstruct status: nil, headers: [], body: :no_body
```
- status: is the http2 result code. You can check the [HTTP/2 Response from APN](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CommunicatingwithAPNs.html#//apple_ref/doc/uid/TP40008194-CH11-SW1) section
- headers: is a list with the response headers
- body: is a list with the body or `:no_body` when no body is returned

##### Timeout
If the call to `Pushito.push/2` returns a `{:timeout, stream_id}` it means your process exceeded the timeout time waiting for a response from APNs. That could be caused because your `timeout` should be greater, because the network went down or maybe other causes.

If you get a timeout it doesn't mean your notification wasn't delivered correctly for sure. If the network went down `chatterbox` (the HTTP/2 client `pushito` relies) will try to connect again and it will send the message when the network goes up. If that is the case the caller process will receive a message on its mail box with the format `{:apns_response, connection_pid, stream_id, response}` where the `connection_pid` is the connection pid (same as `Process.whereis(connection_name)`) and the `stream_id` is the notification identifier returned in the timeout tuple.

## Closing Connections

Apple recommends us to keep our connections open and avoid opening and closing very often. You can check the [Best Practices for Managing Connections](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CommunicatingwithAPNs.html).

But when closing a connection makes sense `pushito` gives us the function `Pushito.close/1` where the parameter is the connection's name. After closing a connection the name will be available for new connections again.

## Tests

For now `pushito` tests against APNs servers without mocks. For this reason you must fill the `config/test.exs` file with your correct information:

```elixir
config :pushito,
  cert_file: "priv/cert2.pem",
  key_file: "priv/key2-noenc.pem",
  apple_host: "api.push.apple.com"
  device_id: "bd5c3ad01bbe4d884bf2fe8801ed77e94a71bc2e9de937c84f745f54eb4cb2f4",
  apns_topic: "com.inaka.myapp",
  token_key_file: "priv/APNsAuthKey_1234567890.p8",
  token_key_id: "1234567890",
  team_id: "THEATEAM"
```

Where
- `cert_file` is the path to your Provider Certificate given by Apple
- `key_file` is your private key, extracted from the certificate
- `apple_host` is the apple host we want to connect:
  -  `api.development.push.apple.com` for development
  -  `api.push.apple.com` for production
- `device_id` is the device's id where you want to push the notification
- `apns_topic` is your application's id
- `token_key_file` is the path to the token key file provided by Apple
- `token_key_id` is the key id provided by Apple
- `team_id` is your team developer id
