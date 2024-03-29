
defmodule EventBus.EventTest do
  use ExUnit.Case

  alias EventBus.Event

  doctest EventBus.Event

  describe "Event.new/1" do
    test "returns error when event is not specified" do
      result = Event.new("wrong_event", %{})

      {:error, :event_not_found} = result
    end

    test "returns error when have too many fields" do
      result =
        [ "user_blocked", "movement_created", "movement_returned" ]
        |> Enum.random()
        |> Event.new(%{"surplus" => "value"})

      {:error, {:surplus_fields, ["surplus"]}} = result
    end

    test "returns error when have missing fields" do
      result =
        "user_blocked"
        |> Event.new(%{"user_id" => Enum.random(1..10)})

      {:ok, %Event{payload: %{}}} = result
    end

    test "converts payload fields in atoms" do
      result =
        "user_blocked"
        |> Event.new(%{"user_id" => Enum.random(1..10)})

      {:ok, %Event{payload: %{user_id: _}}} = result
    end
  end
end
