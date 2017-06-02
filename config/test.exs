use Mix.Config

config :pushito,
  cert_file: "priv/cert2.pem",
  key_file: "priv/key2-noenc.pem",
  apple_host: "api.push.apple.com",
  device_id: "bd5c3ad01bbe4d884bf2fe8801ed77e94a71bc2e9de937c84f745f54eb4cb2f3",
  apns_topic: "com.inaka.myapp",
  token_key_file: "priv/APNsAuthKey_XXXXXXXX.p8",
  token_key_id: "XXXXXXXX",
  team_id: "THEATEAM"
