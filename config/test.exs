use Mix.Config

# Print only warnings and errors during test
config :logger, level: :warn

config :feed_hub, FeedHub.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "feed_hub_repo_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
