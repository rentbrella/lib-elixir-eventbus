defmodule Pub.EventSpec do
  @moduledoc false

  def get("event_name"),
    do: {:ok, [:fields]}

  def get(_), do: {:error, :event_not_found}
end
