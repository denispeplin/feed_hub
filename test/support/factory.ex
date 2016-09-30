defmodule FeedHub.Factory do
  use ExMachina.Ecto, repo: FeedHub.Repo
  use FeedHub.ReloadStrategy
  import ExUnit.TestHelpers, only: [read_rss!: 1]

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
    rss = read_rss!("jobs_feed")
    {_items, feed} = Map.pop(rss, "items")
    %FeedHub.Feed{url: url, data: feed, fetched_at: Ecto.DateTime.utc}
  end

  def with_items(feed) do
    rss = read_rss!("jobs_feed")
    {items, _feed} = Map.pop(rss, "items")
    items
    |> Enum.reverse
    |> Enum.each(fn(data) ->
      guid = data["guid"] |> FeedHub.Utils.value
      insert(:item, feed: feed, data: data, guid: guid)
    end)
    feed
  end

  def item_factory do
    %FeedHub.Item{}
  end
end
