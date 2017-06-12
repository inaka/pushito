# Pushito
APNS over HTTP/2 for Elixir. Inspired on Erlang the project [apns4erl](https://github.com/inaka/apns4erl)

Copyright (c) 2017 Erlang Solutions Ltd. <support@inaka.net>, released under the Apache 2 license

Check the [Online documentation](http://hexdocs.pm/pushito)

**note** this project is under development

## Contact Us
For **questions** or **general comments** regarding the use of `Pushito`, please use our public
[hipchat room](http://inaka.net/hipchat).

If you find any **bugs** or have a **problem** while using `Pushito`, please [open an issue](https://github.com/inaka/pushito/issues/new) in this repo (or a pull request :)).

And you can check all of our open-source projects at [inaka.github.io](http://inaka.github.io)

## Installation

Add `Pushito` to your list of dependencies:

```elixir
def deps do
  [{:pushito, "~> 0.1.0"}]
end
```

And start it

```elixir
[extra_applications: [:logger, :pushito]
```

## Example

There are two types of connection with APNs, `Provider Certificate` (`cert`) and `Provider Authentication Token` (`token`). The first one uses ssl certificates and the second one uses a `JWT` token per each request.

First we need a `Pushito.Config` struct, we are going to create a `cert` type:

```elixir
import Pushito.Config

config = new()
         |> add_name(:my_first_connection)
         |> add_type(:cert)
         |> add_host("api.development.push.apple.com")
         |> add_cert_file("priv/cert2.pem")
         |> add_key_file("priv/key2-noenc.pem")
```

Now we can connect to APNs:

```elixir
Pushito.connect config
```

We can push notification over that connection. First we need a `Pushito.Notification` struct:

```elixir
import Pushito.Notification

notification = new()
               |> add_device_id("bd5c3ad01bbe4d884bf2fe8801ed77e94a71bc2e9de937c84f745f54eb4cb2f4")
               |> add_topic("com.inaka.myapp")
               |> add_message(%{:aps => %{:alert => "you have a message!!"}})
```

Now we can push it!

```elixir
Pushito.push :my_connection, notification
```

In my case I got this:

```elixir
%Pushito.Response{body: :no_body,
 headers: [{"apns-id", "34F4B4F4-ADB6-982F-EB23-36632837520C"}], status: 200}
 ```

 *Note* the process which calls `Pushito.connect/1` should be the same which calls `Pushito.push/2`

## Important Links

- [Online Documentation](http://hexdocs.pm/pushito)

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
