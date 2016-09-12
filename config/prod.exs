use Mix.Config

config :feed_hub, FeedHub.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "feed_hub_repo_prod",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
