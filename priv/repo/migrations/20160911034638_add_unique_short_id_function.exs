defmodule FeedHub.Repo.Migrations.AddUniqueShortIdFunction do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS \"pgcrypto\""

    Path.join("priv/repo/migrations", "unique_short_id.sql")
    |> File.read!
    |> execute
  end

  def down do
    execute "DROP FUNCTION unique_short_id()"
  end
end
