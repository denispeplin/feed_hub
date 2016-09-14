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

  def call(source) do
    do_fetch(source)
    |> to_map
    |> save
  end

  def do_fetch(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "Can't get feed, it responds with #{status_code}"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason |> parse_reason}
    end
  end

  defp parse_reason(reason) when is_binary(reason) do
    reason
  end
  defp parse_reason(reason) do
    reason |> inspect
  end

  def to_map({:ok, source}) do
    {:ok, RssFlow.parse(source)}
  end
  def to_map(error), do: error

  # TODO: inplement saving into Postgres cache
  def save({:ok, map}) do
    {:ok, map}
  end
  def save(error), do: error
end
