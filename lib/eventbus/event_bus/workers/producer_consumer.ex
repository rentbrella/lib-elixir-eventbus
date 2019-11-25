defmodule EventBus.Workers.ProducerConsumer do
  @moduledoc """
  The GenStage ProducerConsumer.

  This module is responsible by
  intermediary message filters,
  for instance, discarting events
  which not own callback functions
  configured.

  You don't need or must call
  any function of this module directly

  More details in [Processing functions](EventBus.html#module-processing-functions)
  """

  use GenStage

  require Logger

  alias EventBus.Event
  alias EventBus.SQSMessage

  alias EventBus.Workers.Producer
  alias EventBus.Queue.Acknowledger

  @doc false
  def start_link() do
    GenStage.start_link(__MODULE__, :doesnt_matter, name: __MODULE__)
  end

  @doc false
  def init(state),
    do: {:producer_consumer, state, subscribe_to: [Producer]}

  @doc false
  def handle_events(messages, _from, state) do
    messages =
      messages
      |> group_messages_by_vality()
      |> discart_invalid_messages()
      |> ack_uninteresting_messages()
      |> set_function_to_process()

    {:noreply, messages, state}
  end

  defp group_messages_by_vality(messages) do
    Enum.reduce(messages, %{valid: [], invalid: []},
      fn message, %{valid: valid, invalid: invalid} = acc ->
        case message do
          %SQSMessage{has_valid_event?: true}  ->
            Map.put(acc, :valid, valid ++ [message])

          %SQSMessage{has_valid_event?: false} ->
            Map.put(acc, :invalid, invalid ++ [message])
        end
      end
    )
  end

  defp discart_invalid_messages(%{invalid: invalids, valid: valids}) do
    Enum.each(invalids, fn message ->
      Logger.error("Message #{message.message_id} is invalid. Discarting")

      Acknowledger.run(message)
    end)

    valids
  end

  defp ack_uninteresting_messages(valid_messages) do
    case Application.get_env(:lib_event_bus, :callbacks) do
      nil -> valid_messages
      []  -> valid_messages

      events when is_list(events) ->
        configurated_events =
          Enum.map(events, fn {event, _} ->
            event
          end)

        Enum.reduce(valid_messages, [], fn message, acc ->
          if Enum.member?(configurated_events, event_from_message(message)) do
            acc ++ [message]
          else
            Logger.info("Message #{message.message_id} is not interesting. Discarting")

            Acknowledger.run(message)

            acc
          end
        end)
    end
  end

  defp event_from_message(%SQSMessage{event: %Event{event: event_name}}),
    do: event_name

  defp set_function_to_process(messages) do
    Enum.map(messages, fn message ->
      Application.get_env(:lib_event_bus, :callbacks)
      |> Enum.reduce([], fn {event_name, function}, acc ->
        if event_name == event_from_message(message) do
          acc ++ [{message, function}]
        else
          acc
        end
      end)
    end)
    |> List.flatten()
  end
end
