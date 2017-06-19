# PushPool

This project is an example of using `Pushito` with `poolboy`

## Installation

This example has `pushito` and `poolboy` as a dependencies. First we have to fetch and compile them:

```
$ mix deps.get
$ mix deps.compile
```

This example creates `:cert` connections. You must to generate your own certificate files as we explain [here](../pusher/README.md)
After that you must fill your `config/config.exs` according with your information:

```elixir
config :pushito,
  cert_file: "priv/cert2.pem",
  key_file: "priv/key2-noenc.pem",
  apple_host: "api.push.apple.com",
  apns_topic: "com.madebybowtie.Knuff-iOS"
```

Then start the application

```
$ iex -S mix
```

## Use

The `PushPool` api is quite straightforward. There are only 2 functions:
- `PushPool.notification/2`: it is a helper for creating `Pushito.Notifications` easily. The first argument is the device_id
and the second one is the message.
-  

```
iex(1)> device_id = "bd5c3ad01bbe4d884bf2fe8801ed77e94a71bc2e9de937c84f745f54eb4cb2f4"
"bd5c3ad01bbe4d884bf2fe8801ed77e94a71bc2e9de937c84f745f54eb4cb2f4"
iex(2)> PushPool.notification("hello my friend!", device_id) |> PushPool.push
%Pushito.Response{body: :no_body,
 headers: [{"apns-id", "B283CC2C-97D6-0FA4-2DAD-1976AAAC60AE"}], status: 200}
 ```
