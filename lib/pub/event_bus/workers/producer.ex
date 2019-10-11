defmodule Pub.Workers.Producer do
  @moduledoc """
  The GenStage Producer.

  This module is responsible
  by continuously query SQS
  about new messages, which
  will be consumed by ProducerConsumer

  More details in [Processing functions](Pub.html#module-processing-functions)
  """
  use GenStage

  require Logger

  alias Pub.Queue

  @doc false
  def start_link do
    GenStage.start_link(__MODULE__, :doesnt_matter, name: __MODULE__)
  end

  @doc false
  def init(arg), do: {:producer, arg}

  @doc false
  def handle_demand(demand, state) do
    messages =
      demand
      |> get_messages()

    Process.send_after(self(), :consume, 1000)

    {:noreply, messages, state}
  end

  @doc false
  def handle_info(:consume, state) do
    messages = get_messages(10)

    Logger.info("Searching for new messages in SQS")

    Process.send_after(self(), :consume, 1000)

    {:noreply, messages, state}
  end

  @doc false
  def handle_info({:ssl_closed, _}, state) do
    Logger.warn("Received :ssl_closed in producer")

    {:noreply, [], state}
  end

  defp get_messages(demand) do
    "AWS_SQS_QUEUE"
    |> System.get_env()
    |> Queue.Receiver.run(demand)
  end
end