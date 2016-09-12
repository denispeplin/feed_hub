defmodule FeedHub.Repo.Migrations.CreateCommandSets do
  use Ecto.Migration

  def change do
    create table(:command_sets) do
      add :data, :map, null: false
    end
  end
end
