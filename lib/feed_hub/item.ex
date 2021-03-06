defmodule FeedHub.Item do
  use Ecto.Schema
  #require Ecto.Query
  import Ecto.Query, only: [from: 2]
  import FeedHub.Utils, only: [value: 1]
  alias FeedHub.Repo

  schema "items" do
    belongs_to :feed, FeedHub.Feed

    field :guid, :string
    field :data, :map

    timestamps
  end

  def validate_changeset(feed, params \\ %{}) do
    feed
    |> Ecto.Changeset.cast(params, [:feed_id, :guid, :data])
    |> Ecto.Changeset.validate_required([:feed_id, :guid, :data])
  end

  def save(feed_id, data) do
    guid = data[:guid] |> value
    existing_item = Repo.get_by(__MODULE__, guid: guid)
    if existing_item do
      {:ok, existing_item}
    else
      changeset = validate_changeset(
        %__MODULE__{},
        %{feed_id: feed_id, guid: guid, data: data}
      )
      Repo.insert(changeset)
    end
  end

  def data_by_feed_id(feed_id) do
    from(i in "items",
      where: i.feed_id == ^feed_id,
      order_by: [desc: :id],
      select: i.data
    ) |> Repo.all
  end
end
