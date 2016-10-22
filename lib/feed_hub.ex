defmodule FeedHub do
  use Application
  alias FeedHub.CommandSet

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: FeedHub.Worker.start_link(arg1, arg2, arg3)
      # worker(FeedHub.Worker, [arg1, arg2, arg3]),
      supervisor(FeedHub.Repo, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FeedHub.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc """
  Creates `command set` from JSON
  Returns UID of created command set.
  UID can be used to run command set and get resulting feed
  """
  def create(data) do
    CommandSet.create(data)
  end

  @doc """
  Runs command set and composes resulting feed
  """
  def feed(uid) do
    CommandSet.feed(uid)
  end
end
