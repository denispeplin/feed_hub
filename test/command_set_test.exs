defmodule FeedHub.CommandSetTest do
  use ExUnit.Case
  import FeedHub.Factory
  import Mock
  alias FeedHub.CommandSet

  defp errors_on(model \\ %CommandSet{}, data) do
    CommandSet.changeset(model, data).errors
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
  end

  describe "fetch/1" do
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

    test "empty feed source" do
      command_set = %{
        "commands" => ["fetch"]
      }

      assert CommandSet.parse(command_set) == {:error, "No feed source"}
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
        assert CommandSet.run({:ok, commands}) == :ok
        assert called FeedHub.Commands.Fetch.call(data)
      end
    end
  end
end
