defmodule FeedHub.Commands.Fetch do
  defstruct data: nil

  def init(nil), do: {:error, "No feed source"}
  def init(""), do: {:error, "Empty feed source"}
  def init(source) do
    if valid?(source) do
      %__MODULE__{data: source}
    else
      {:error, "Invalid URL"}
    end
  end

  defp valid?(url) do
    case URI.parse(url) do
      %URI{scheme: nil} -> false
      %URI{host: nil, path: nil} -> false
      _ -> true
    end
  end

  # TODO: implement fetching into cache
  def call(source) do
    IO.puts source
  end
end
