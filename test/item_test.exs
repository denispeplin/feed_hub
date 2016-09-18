defmodule FeedHub.ItemTest do
  use ExUnit.Case, async: true
  import FeedHub.Factory
  alias FeedHub.Item
  alias FeedHub.Repo
  import ExUnit.TestHelpers, only: [stringify_keys: 1]

  defp errors_on(model \\ %Item{}, data) do
    Item.validate_changeset(model, data).errors
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "validations" do
    test "data must be present" do
      errors = errors_on(%{})
      assert {:feed_id, {"can't be blank", []}} in errors
      assert {:guid, {"can't be blank", []}} in errors
      assert {:data, {"can't be blank", []}} in errors
    end
  end

  describe "save/2" do
    test "save an item with feed_id and data" do
      feed = insert :feed
      guid = "guid"
      data = %{guid: guid}

      {:ok, saved_item} = Item.save(feed.id, data)
      item = Repo.get(Item, saved_item.id)
      assert item.feed_id == feed.id
      assert item.guid == guid
      assert item.data == (data |> stringify_keys)

      {:ok, item_same_guid} = Item.save(feed.id, data)
      assert item == item_same_guid
    end
  end
end
