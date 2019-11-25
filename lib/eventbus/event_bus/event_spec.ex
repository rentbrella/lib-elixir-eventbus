defmodule EventBus.EventSpec do
  @moduledoc false

  def get("user_blocked"),
    do: {:ok, {"2019-05-11", [:user_id]}}

  def get("movement_created") do
    {:ok,
     {"2019-05-11",
      [
        :id,
        :status,
        :user,
        :machine,
        :pull_place,
        :push_place,
        :created_at,
        :expires_at,
        :finished_at
      ]}}
  end

  def get("movement_changed") do
    {:ok,
     {"2019-05-11",
      [
        :id,
        :status,
        :user,
        :machine,
        :pull_place,
        :push_place,
        :created_at,
        :expires_at,
        :finished_at
      ]}}
  end

  def get("occurrence_created") do
    {:ok,
     {"2019-06-25",
      [
        :id,
        :user_id,
        :machine_id,
        :movement_id,
        :status,
        :created_at,
        :updated_at
      ]}}
  end

  def get(_), do: {:error, :event_not_found}
end

