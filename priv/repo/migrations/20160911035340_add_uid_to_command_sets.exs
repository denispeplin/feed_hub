defmodule FeedHub.Repo.Migrations.AddUidToCommandSets do
  use Ecto.Migration

  def up do
    alter table(:command_sets) do
      add :uid, :string
    end

    create index(:command_sets, :uid, unique: true)

    execute """
    CREATE TRIGGER trigger_genid
    BEFORE INSERT ON command_sets
    FOR EACH ROW EXECUTE PROCEDURE unique_short_id()
    """
  end

  def down do
    execute "DROP TRIGGER trigger_genid ON command_sets"

    drop index(:command_sets, :uid)

    alter table(:command_sets) do
      remove :uid
    end
  end
end
