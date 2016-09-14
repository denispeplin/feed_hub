defmodule FeedHub.Commands.FetchTest do
  use ExUnit.Case
  import Mock
  import ExUnit.TestHelpers, only: [read_file!: 1]

  describe "init/1" do
    test "assigns data on init" do
      assert FeedHub.Commands.Fetch.init("http://example.com/feed33") ==
        %FeedHub.Commands.Fetch{data: "http://example.com/feed33"}
    end
  end

  describe "call/1" do
    test "downloads a source" do
      source = "http://example.com"
      body = read_file!("jobs_feed.rss")
      response = {:ok, %HTTPoison.Response{status_code: 200, body: body}}
      with_mock HTTPoison, [get: fn(_) -> response end] do
        assert FeedHub.Commands.Fetch.call(source) == {:ok, RssFlow.parse(body)}
        assert called HTTPoison.get(source)
      end
    end
  end
end
