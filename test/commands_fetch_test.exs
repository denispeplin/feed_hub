defmodule FeedHub.Commands.FetchTest do
  use ExUnit.Case
  require Ecto.Query
  alias FeedHub.Feed
  alias FeedHub.Item
  alias FeedHub.Repo
  import Mock
  import ExUnit.TestHelpers, only: [read_file!: 1, stringify_keys: 1]

  describe "init/1" do
    test "assigns data on init" do
      assert FeedHub.Commands.Fetch.init("http://example.com/feed33") ==
        %FeedHub.Commands.Fetch{data: "http://example.com/feed33"}
    end
  end

  describe "call/1" do
    setup do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    end

    test "downloads a source" do
      source = "http://example.com"
      rss = read_file!("jobs_feed.rss")
      parsed_rss = RssFlow.parse(rss)
      parsed_rss_strings = parsed_rss |> stringify_keys
      response = {:ok, %HTTPoison.Response{status_code: 200, body: rss}}
      with_mock HTTPoison, [get: fn(_) -> response end] do
        assert FeedHub.Commands.Fetch.call(source) == {:ok, parsed_rss}
        assert called HTTPoison.get(source)
        feed = Repo.get_by(Feed, url: source)

        assert feed
        assert feed.url == source
        feed_data = Map.take(parsed_rss_strings, ["rss", "channel"])
        assert feed.data == feed_data

        feed_id = feed.id
        items = Item |> Ecto.Query.where(feed_id: ^feed_id) |> Repo.all
        assert is_list(items)
        assert length(items) == 4
      end
    end
  end
end
