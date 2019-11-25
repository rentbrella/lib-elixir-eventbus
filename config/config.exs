use Mix.Config

config :lib_event_bus,
  callbacks: [
    {"user_blocked",      fn %{message_id: _id} -> :ok end},
    {"movement_created",  fn %{message_id: _id} -> :ok end},
    {"movement_returned", fn %{message_id: _id} -> :ok end}
  ],
  test: Rentbrella.EventBus.EventSpec

config :ex_aws,
  json_codec: Jason,
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}]
