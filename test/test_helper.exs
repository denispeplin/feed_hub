ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(FeedHub.Repo, :manual)

{:ok, _} = Application.ensure_all_started(:ex_machina)

defmodule ExUnit.TestHelpers do
  def read_file(filename) do
    System.cwd
    |> Path.join("test/files/#{filename}")
    |> File.read
  end
  def read_file!(filename) do
    case read_file(filename) do
      {:ok, binary} ->
        binary
      {:error, reason} ->
        raise File.Error, reason: reason, action: "read file",
          path: IO.chardata_to_string(filename)
    end
  end

  def stringify_keys(map) do
    map |> Poison.encode! |> Poison.decode!
  end
end
