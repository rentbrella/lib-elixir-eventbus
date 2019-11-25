defmodule EventBus.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  import Supervisor.Spec, warn: false

  alias EventBus.Application.Validator

  def start(_type, _args) do
    Application.get_env(:lib_event_bus, :callbacks)
    |> Validator.validate_configuration()

    Validator.validate_environment()

    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: EventBus.Worker.start_link(arg)
      worker(EventBus.Workers.Producer, []),
      worker(EventBus.Workers.ProducerConsumer, []),
      worker(EventBus.Workers.Consumer, [])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: EventBus.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
