defmodule FeedHub.Commands.FetchTest do
  use ExUnit.Case

  describe "init/1" do
    test "assigns data on init" do
      assert FeedHub.Commands.Fetch.init("http://example.com/feed33") ==
        %FeedHub.Commands.Fetch{data: "http://example.com/feed33"}
    end
  end
end
