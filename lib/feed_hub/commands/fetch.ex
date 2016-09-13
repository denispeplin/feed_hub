defmodule FeedHub.Commands.Fetch do
  defstruct data: nil

  def init(data) do
    %__MODULE__{data: data}
  end

  # TODO: implement fetching into cache
  def call(source) do
    IO.puts source
  end
end
