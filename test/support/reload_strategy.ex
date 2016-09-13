defmodule FeedHub.ReloadStrategy do
  use ExMachina.Strategy, function_name: :reload

  def handle_reload(record, _opts) do
    FeedHub.Repo.get(record.__struct__, record.id)
  end
end
