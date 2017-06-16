use Mix.Config

config :pushito,
  cert_file: "priv/cert2.pem",
  key_file: "priv/key2-noenc.pem",
  apple_host: "api.push.apple.com",
  apns_topic: "com.madebybowtie.Knuff-iOS"
