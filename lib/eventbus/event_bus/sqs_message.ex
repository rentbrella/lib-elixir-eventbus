defmodule EventBus.SQSMessage do
  alias __MODULE__

  alias EventBus.Event
  alias EventBus.EventSpec

  @type t :: %__MODULE__{
    message_id: binary(),
    receipt_handle: binary(),
    raw_body: binary() | map(),
    queue_name: binary(),
    event: Event.t(),
    has_valid_event?: boolean()
  }

  defstruct [
    :message_id,
    :receipt_handle,
    :raw_body,
    :queue_name,

    event: %Event{},
    has_valid_event?: false
  ]

  @spec new(map(), binary()) :: t()
  def new(message, queue_name) do
    %SQSMessage{}
    |> set_queue_name(queue_name)
    |> set_message_id(message)
    |> set_receipt_handle(message)
    |> set_raw_body(message)
    |> set_decoded_body(message)
    |> set_event(message)
  end

  defp set_queue_name(struct, queue_name) do
    Map.put(struct, :queue_name, queue_name)
  end

  defp set_message_id(struct, %{message_id: id}) do
    Map.put(struct, :message_id, id)
  end

  defp set_receipt_handle(struct, %{receipt_handle: rh}) do
    Map.put(struct, :receipt_handle, rh)
  end

  defp set_raw_body(struct, %{body: body}) do
    Map.put(struct, :raw_body, body)
  end

  defp set_decoded_body(%SQSMessage{raw_body: body} = struct, _) do
    case Jason.decode(body) do
      {:ok, decoded} ->
        Map.put(struct, :raw_body, decoded)

      _another -> struct
    end
  end

  defp set_event(%SQSMessage{raw_body: %{"Message" => event}} = struct, _) do
    case Jason.decode(event) do
      {:ok, decoded} ->
        validate_and_set_event(struct, decoded)

      _another -> struct
    end
  end
  defp set_event(struct, _), do: struct

  defp validate_and_set_event(struct, decoded) do
    case decoded do
      %{"event" => event_name, "payload" => payload} ->
        case EventSpec.get(event_name) do
          {:error, :event_not_found} -> struct

          _another ->
            case Event.new(event_name, payload) do
              {:ok, event} ->
                struct
                |> Map.put(:event, event)
                |> Map.put(:has_valid_event?, true)

              {:error, _} -> struct
            end
        end

      _another -> struct
    end
  end
end
