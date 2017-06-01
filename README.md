# pushito
APNS over HTTP/2 for Elixir. Inspired on Erlang the project [apns4erl](https://github.com/inaka/apns4erl)

Copyright (c) 2017 Erlang Solutions Ltd. <support@inaka.net>, released under the Apache 2 license

**note** this project is under development

## Contact Us
For **questions** or **general comments** regarding the use of `Pushito`, please use our public
[hipchat room](http://inaka.net/hipchat).

If you find any **bugs** or have a **problem** while using `Pushito`, please [open an issue](https://github.com/inaka/pushito/issues/new) in this repo (or a pull request :)).

And you can check all of our open-source projects at [inaka.github.io](http://inaka.github.io)

## Tests

For now `pushito` tests against APNs servers without mocks. For this reason you mus fill the `config/test.exs` file with your correct information:

```elixir
config :pushito,
  cert_file: "priv/cert2.pem",
  key_file: "priv/key2-noenc.pem",
  apple_host: "api.push.apple.com"
  device_id: "bd5c3ad01bbe4d884bf2fe8801ed77e94a71bc2e9de937c84f745f54eb4cb2f4",
  apns_topic: "com.inaka.myapp"
```

Where
- `cert_file` is the path to your Provider Certificate given by Apple.
- `key_file` is your private key, extracted from the certificate.
- `apple_host` is the apple host we want to connect:
  -  `api.development.push.apple.com` for development
  -  `api.push.apple.com` for production
- `device_id` is the device's id where you want to push the notification
- `apns_topic` is your application's id
