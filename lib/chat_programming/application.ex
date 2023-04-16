defmodule ChatProgramming.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ChatProgrammingWeb.Telemetry,
      # Start the Ecto repository
      ChatProgramming.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: ChatProgramming.PubSub},
      # Start Finch
      {Finch, name: ChatProgramming.Finch},
      # Start the Endpoint (http/https)
      ChatProgrammingWeb.Endpoint
      # Start a worker by calling: ChatProgramming.Worker.start_link(arg)
      # {ChatProgramming.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ChatProgramming.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ChatProgrammingWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
