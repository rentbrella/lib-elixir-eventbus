defmodule Pub.Event do
  @moduledoc "Represents a Event"

  @derive Jason.Encoder
  defstruct [:payload, :event]

  @type t :: %__MODULE__{
          payload: map(),
          event: binary()
        }

  alias __MODULE__

  alias Pub.EventSpec

  @doc """
  Creates new Event's struct

  ### Examples
      iex> Pub.Event.new("event1", %{"user_id" => 1})
      {:ok,
        %Pub.Event{
        event: "event1",
        payload: %{user_id: 1}
      }}
  """
  @spec new(binary(), map()) :: {:ok, t()} | {:error, atom, list}
  def new(event_name, %{} = payload) when is_binary(event_name) do
    %Event{}
    |> Map.put(:event, event_name)
    |> Map.put(:payload, payload)
    |> validate_and_transform()
  end

  defp validate_and_transform(%{event: event_name} = event) do
    case EventSpec.get(event_name) do
      {:error, reason} ->
        {:error, reason}

      {:ok, spec_fields} ->
        event
        |> compare_payload_with_spec(spec_fields)
    end
  end

  defp compare_payload_with_spec(%{payload: payload} = event, spec_fields) do
    case compare_field_lists(payload, spec_fields) do
      [] ->
        case compare_field_lists(spec_fields, payload) do
          [] ->
            payload =
              payload
              |> Enum.reduce(%{}, fn {key, value}, acc ->
                key =
                  if is_atom(key) do
                    key
                  else
                    String.to_existing_atom(key)
                  end

                Map.put(acc, key, value)
              end)

            {:ok, Map.put(event, :payload, payload)}

          fields ->
            {:error, {:missing_fields, fields}}
        end

      fields ->
        {:error, {:surplus_fields, fields}}
    end
  end

  defp compare_field_lists(%{} = left, right),
    do: compare_field_lists(Map.keys(left), right)

  defp compare_field_lists(left, %{} = right),
    do: compare_field_lists(left, Map.keys(right))

  defp compare_field_lists(left, right) do
    left = atom_fields_to_string(left)
    right = atom_fields_to_string(right)

    left -- right
  end

  defp atom_fields_to_string(fields) do
    fields
    |> Enum.map(fn field ->
      if is_atom(field) do
        Atom.to_string(field)
      else
        field
      end
    end)
  end
end
