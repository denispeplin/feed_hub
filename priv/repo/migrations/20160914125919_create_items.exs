defmodule FeedHub.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :feed_id, references(:feeds), null: false
      add :guid, :string, null: false
      add :data, :map, null: false

      timestamps
    end

    create index(:items, [:feed_id, :guid], unique: true)
  end
end
