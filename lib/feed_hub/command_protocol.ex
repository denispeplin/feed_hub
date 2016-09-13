defprotocol Command do
  @doc "Runs command"
  def run(command)
end

defimpl Command, for: FeedHub.Commands.Fetch do
  def run(struct) do
    struct.__struct__.call(struct.data)
  end
end
