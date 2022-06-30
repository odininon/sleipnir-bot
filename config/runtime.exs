import Config

config :nostrum,
  token: System.get_env("DISCORD_TOKEN"),
  num_shards: :auto,
  gateway_intents: [:message_content, :guilds, :guild_messages]
