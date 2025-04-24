defmodule UsersService.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      UsersServiceWeb.Telemetry,
      UsersService.Repo,
      {DNSCluster, query: Application.get_env(:users_service, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: UsersService.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: UsersService.Finch},
      # Start a worker by calling: UsersService.Worker.start_link(arg)
      # {UsersService.Worker, arg},
      # Start to serve requests, typically the last entry
      UsersServiceWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: UsersService.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    UsersServiceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
