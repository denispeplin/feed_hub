defmodule FeedHub.Repo.Migrations.CreateFeeds do
  use Ecto.Migration

  def change do
    create table(:feeds) do
      add :url, :string, null: false
      add :fetched_at, :datetime, null: false
      add :data, :map, null: false

      timestamps
    end

    create index(:feeds, [:url], unique: true)
  end
end
