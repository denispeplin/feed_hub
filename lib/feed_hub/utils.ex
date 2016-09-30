defmodule FeedHub.Utils do
  @moduledoc """
  Various utils
  """

  @doc """
  Extracts value from RSS attribute

  ## Examples
      iex> FeedHub.Utils.value "simple string"
      "simple string"
      iex> FeedHub.Utils.value %{some_attribute: "attribute", value: "value"}
      "value"
  """
  def value(%{value: value}), do: value
  def value(%{"value" => value}), do: value
  def value(value), do: value
end
