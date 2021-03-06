defmodule FeedHub.CommandSetTest do
  use ExUnit.Case
  import FeedHub.Factory
  import Mock
  alias FeedHub.CommandSet
  import ExUnit.TestHelpers, only: [read_file!: 1, read_rss!: 1]

  defp errors_on(model \\ %CommandSet{}, data) do
    CommandSet.validate_changeset(model, data).errors
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(FeedHub.Repo)
  end

  describe "validations" do
    test "data must be present" do
      assert {:data, {"can't be blank", []}} in errors_on(%{})
    end
  end

  describe "create/1" do
    test "create a fetch command" do
      command_set = %{
        commands: ["fetch"],
        fetch: "http://example.com/feed1"
      }

      {:ok, uid} = FeedHub.CommandSet.create(command_set)
      assert String.length(uid) == 8
    end

    test "validation error" do
      {:error, message} = FeedHub.CommandSet.create(nil)
      assert message == [data: {"can't be blank", []}]
    end
  end

  describe "feed/1" do
    test "feed composes feed from uid" do
      command_set = build(:command_set) |> with_fetch |> insert
      source = command_set.data.fetch
      insert(:feed, url: source) |> with_items

      rss = read_file!("jobs_feed.rss")
      response = {:ok, %HTTPoison.Response{status_code: 200, body: rss}}
      with_mock HTTPoison, [get: fn(_) -> response end] do
        assert FeedHub.CommandSet.feed(command_set.uid) == read_rss!("jobs_feed")
        assert FeedHub.Commands.Fetch.call(source) == {:ok, source}
        assert called HTTPoison.get(source)
      end
    end
  end

  describe "get/1" do
    test "fetches command set by uid" do
      command_set = build(:command_set) |> with_fetch |> insert |> reload

      assert FeedHub.CommandSet.get(command_set.uid) == command_set.data
    end

    test "returns error for missing command" do
      assert FeedHub.CommandSet.get("fake_uid") == {:error, "Command set not found"}
    end
  end

  describe "parse/1" do
    test "parse command set into sequence of commands" do
      command_set = %{
        "commands" => ["fetch"],
        "fetch" => "http://example.com/feed1"
      }

      assert CommandSet.parse(command_set) ==
        {:ok, [%FeedHub.Commands.Fetch{data: command_set["fetch"]}]}
    end

    test "empty commands list" do
      assert CommandSet.parse(%{"commands" => []}) == {:error, "Commands list is empty"}
    end

    test "commands are not a list" do
      assert CommandSet.parse(%{"commands" => ""}) == {:error, "Commands are not a list"}
    end

    test "no commands list" do
      assert CommandSet.parse(%{}) == {:error, "No commands list"}
    end

    test "no feed source" do
      command_set = %{
        "commands" => ["fetch"]
      }

      assert CommandSet.parse(command_set) == {:error, "No feed source"}
    end

    test "empty feed source" do
      command_set = %{
        "commands" => ["fetch"],
        "fetch" => ""
      }

      assert CommandSet.parse(command_set) == {:error, "Empty feed source"}
    end

    test "invalid URL" do
      command_set = %{
        "commands" => ["fetch"],
        "fetch" => "invalid.url"
      }

      assert CommandSet.parse(command_set) == {:error, "Invalid URL"}
    end

    test "duplicated commands" do
      assert CommandSet.parse(%{"commands" => ["fetch", "fetch"]}) ==
        {:error, "There are duplicated commands in the list"}
    end

    test "unsupported commands" do
      assert CommandSet.parse(%{"commands" => ["fetch", "unsupported"]}) ==
        {:error, "Unsupported commands found. Supported commands are: [\"fetch\"]"}
    end
  end

  describe "run/1" do
    test "run with fetch command" do
      data = "http://example.com/feed"
      commands = [%FeedHub.Commands.Fetch{data: data}]

      with_mock FeedHub.Commands.Fetch, [call: fn(_url) -> :ok end] do
        assert CommandSet.run({:ok, commands}) == {:ok, commands}
        assert called FeedHub.Commands.Fetch.call(data)
      end
    end
  end

  describe "compose/1" do
    test "composing feed from cached data" do
      feed = insert(:feed) |> with_items
      assert CommandSet.compose({:ok, feed.url}) == read_rss!("jobs_feed")
    end
  end
end
