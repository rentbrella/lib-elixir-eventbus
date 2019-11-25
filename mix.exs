defmodule EventBus.MixProject do
  use Mix.Project

  def project do
    [
      app: :lib_event_bus,
      version: "1.0.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      name: "EventBus",
      source_url: "https://github.com/rentbrella/lib-elixir-eventbus",
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {EventBus.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.1"},
      {:sweet_xml, "~> 0.6.6"},
      {:hackney, "~> 1.15"},
      {:ex_aws, "~> 2.1"},
      {:ex_aws_sqs, "~> 2.0"},
      {:ex_aws_sns, "~> 2.0"},
      {:gen_stage, "~> 0.11"},
      {:ex_doc, "~> 0.20.2", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "Rentbrella's aws' SQS' package."
  end

  defp package() do
    [
      organization: "Rentbrella",
      name: "lib_elixir_eventbus",
      licenses: [""],
      links: %{
        "Github" => "https://github.com/rentbrella/lib-elixir-eventbus"
      }
    ]
  end

  defp docs() do
    [
      main: "Pub",
      groups_for_modules: [
        "Main Module": [
          Pub
        ],
        "Data Structs": [
          EventBus.Event,
          EventBus.SQSMessage
        ],
        "Queue Interactions": [
          EventBus.Queue.Receiver,
          EventBus.Queue.Publisher,
          EventBus.Queue.Acknowledger
        ],
        "GenStage Modules": [
          EventBus.Workers.Consumer,
          EventBus.Workers.Producer,
          EventBus.Workers.ProducerConsumer
        ]
      ]
    ]
  end
end
