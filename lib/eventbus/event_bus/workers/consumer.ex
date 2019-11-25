defmodule EventBus.Workers.Consumer do
  @moduledoc """
  The GenStage Consumer.

  This module is responsible
  by processing and discart
  successfully processed messages.

  More details in [Processing functions](EventBus.html#module-processing-functions)
  """

  use GenStage

  require Logger

  alias EventBus.SQSMessage

  alias EventBus.Queue.Acknowledger
  alias EventBus.Workers.ProducerConsumer

  @doc false
  def start_link do
    GenStage.start_link(__MODULE__, :doesnt_matter)
  end

  @doc false
  def init(state) do
    {:consumer, state, subscribe_to: [ProducerConsumer]}
  end

  @doc false
  def handle_events(messages, _from, state) do
    Enum.map(messages, &process_message/1)

    {:noreply, [], state}
  end

  defp process_message({%SQSMessage{message_id: id} = message, function}) do
    Logger.info("Processing message #{id}")

    case function.(message) do
      :ok ->
        Logger.info("Message #{id} sucessfully processed. Acknowledging")
        Acknowledger.run(message)

      :error ->
        Logger.error("Error processing message #{id}")
    end
  end
end
