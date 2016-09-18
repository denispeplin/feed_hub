defmodule FeedHub.Feed do
  use Ecto.Schema
  alias FeedHub.Repo

  schema "feeds" do
    field :url, :string
    field :fetched_at, Ecto.DateTime
    field :data, :map

    has_many :items, FeedHub.Item

    timestamps
  end

  def validate_changeset(feed, params \\ %{}) do
    feed
    |> Ecto.Changeset.cast(params, [:url, :data, :fetched_at])
    |> Ecto.Changeset.validate_required([:url, :data, :fetched_at])
  end

  def save(url, data) do
    existing_feed = Repo.get_by(__MODULE__, url: url)
    if existing_feed do
      {:ok, existing_feed}
    else
      changeset = validate_changeset(
        %__MODULE__{},
        %{url: url, data: data, fetched_at: Ecto.DateTime.utc}
      )
      Repo.insert(changeset)
    end
  end
end
