# pushito
APNS over HTTP/2 for Elixir. Inspired on Erlang the project [apns4erl](https://github.com/inaka/apns4erl)

**note** this project is under development

## Tests

For now `pushito` tests against APNs servers without mocks. For this reason you mus fill the `config/test.exs` file with your correct information:

```elixir
config :pushito,
  cert_file: "priv/cert2.pem",
  key_file: "priv/key2-noenc.pem",
  apple_host: "api.push.apple.com"
```

Where
- `cert_file` is the path to your Provider Certificate given by Apple.
- `key_file` is your private key, extracted from the certificate.
- `apple_host` is the apple host we want to connect:
  -  `api.development.push.apple.com` for development
  -  `api.push.apple.com` for production
