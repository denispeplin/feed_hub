defmodule FeedHubTest do
  use ExUnit.Case
  doctest FeedHub
  import Mock
  alias FeedHub.CommandSet

  test "create/1" do
    data = "{json: data}"
    uid = "uid"
    with_mock CommandSet, [create: fn(_) -> uid end] do
      assert FeedHub.create(data) == uid
      assert called CommandSet.create(data)
    end
  end

  test "feed/1" do
    uid = "uid"
    feed = "<rss></rss>"
    with_mock CommandSet, [feed: fn(_) -> feed end] do
      assert FeedHub.feed(uid) == feed
      assert called CommandSet.feed(uid)
    end
  end
end
