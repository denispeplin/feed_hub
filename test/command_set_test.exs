defmodule FeedHub.CommandSetTest do
  use ExUnit.Case, async: true
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
      command = %{
        commands: ["fetch"],
        fetch: "http://example.com/feed1"
      }

      {:ok, uid} = FeedHub.CommandSet.create(command)
      assert String.length(uid) == 8
    end
  end
end
