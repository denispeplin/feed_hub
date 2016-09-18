defmodule FeedHub.FeedTest do
  use ExUnit.Case, async: true
  alias FeedHub.Feed
  alias FeedHub.Repo

  defp errors_on(model \\ %Feed{}, data) do
    Feed.validate_changeset(model, data).errors
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "validations" do
    test "data must be present" do
      errors = errors_on(%{})
      assert {:data, {"can't be blank", []}} in errors
      assert {:url, {"can't be blank", []}} in errors
    end
  end

  describe "save/2" do
    test "saving URL and data" do
      url = "http://example.com"
      data = %{} # no check for actual data yet
      {:ok, feed} = FeedHub.Feed.save(url, data)
      assert feed.url == url
      assert feed.data == data
      assert feed.fetched_at

      {:ok, feed_same_url} = FeedHub.Feed.save(url, data)
      assert feed == feed_same_url
    end
  end
end
