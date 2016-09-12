defmodule FeedHub.CommandSet do
  @moduledoc """
  Handling command sets.
  """
  use Ecto.Schema
  alias FeedHub.Repo

  schema "command_sets" do
    field :data, :map
    field :uid, :string
  end

  def changeset(command_set, params \\ %{}) do
    command_set
    |> Ecto.Changeset.cast(params, [:data])
    |> Ecto.Changeset.validate_required([:data])
  end

  @doc """
  Creates command set, returns feed ID.
  """
  def create(data) do
    changeset = changeset(%FeedHub.CommandSet{}, %{data: data})
    case Repo.insert(changeset) do
      {:ok, command_set} ->
        # want to use RETURNING "id", "uid" instead of reloading,
        # but don't know how to do it.
        {:ok, Repo.get!(FeedHub.CommandSet, command_set.id).uid}
      {:error, changeset} ->
        {:error, changeset.errors}
    end
  end
end
