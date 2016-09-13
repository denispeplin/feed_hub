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

  @commands %{"fetch" => FeedHub.Commands.Fetch}

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
        {:ok, Repo.get!(__MODULE__, command_set.id).uid}
      {:error, changeset} ->
        {:error, changeset.errors}
    end
  end

  def get(uid) do
    __MODULE__
    |> Repo.get_by(uid: uid)
    |> handle_get
  end
  defp handle_get(nil) do
    {:error, "Command set not found"}
  end
  defp handle_get(command_set) do
    command_set.data
  end

  @doc """
  Transform command set map to a sequence of commands
  """
  def parse({:error, _} = error) do
    error
  end
  def parse(command_set) do
    do_parse(command_set)
  end

  defp do_parse(%{"commands" => commands} = command_set_data)
    when is_list(commands) and length(commands) > 0 do
    cond do
      length(commands) != length(Enum.uniq(commands)) ->
        {:error, "There are duplicated commands in the list"}
      Enum.any?(commands, fn(command) -> @commands[command] == nil end) ->
        {
          :error,
          "Unsupported commands found. Supported commands are: #{@commands |> Map.keys |> inspect}"
        }
      true ->
        # TODO: return erorrs from command modules inits
        {
          :ok,
          Enum.map(commands, fn(command) -> @commands[command].init(command_set_data[command]) end)
        }
      end
  end
  defp do_parse(%{"commands" => commands}) when is_list(commands) do
    {:error, "Commands list is empty"}
  end
  defp do_parse(%{"commands" => _}) do
    {:error, "Commands are not a list"}
  end
  defp do_parse(_) do
    {:error, "No commands list"}
  end

  def run({:ok, commands}) do
    do_run(commands)
    :ok
  end
  def run({:error, message} = error), do: error

  # TODO: implement run for all commands, not only first
  def do_run([command | _commands]) do
    Command.run(command)
  end
end
