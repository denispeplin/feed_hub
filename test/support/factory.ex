defmodule FeedHub.Factory do
  use ExMachina.Ecto, repo: FeedHub.Repo
  use FeedHub.ReloadStrategy

  def command_set_factory do
    %FeedHub.CommandSet{}
  end

  def with_fetch(command_set) do
    data = %{
      commands: ["fetch"],
      fetch: sequence(:fetch_data, &"http://example.com/feed#{&1}")
    }
    %{command_set | data: data}
  end

  def feed_factory do
    url = sequence(:feed_url, &"http://example.com/feed-#{&1}")
    %FeedHub.Feed{url: url, data: %{}, fetched_at: Ecto.DateTime.utc}
  end
end
