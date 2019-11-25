defmodule EventBus.Queue.Publisher do
  alias ExAws.SNS

  alias EventBus.Event

  @doc "Sends a `event` to a SNS `topic`"
  @spec run(Event.t() | {:ok, Event.t()}, binary) :: {:ok, map} | {:error, any}
  def run(event),
    do: run(event, System.get_env("AWS_SNS_TOPIC_ARN"))
  def run({:ok, event = %Event{}}, topic_arn) do
    run(event, topic_arn)
  end
  def run(%Event{} = event, topic_arn) do
    case Jason.encode(event) do
      {:ok, json} -> publish(json, topic_arn)
      another -> another
    end
  end

  defp publish(event, topic_arn) when is_binary(event) do
    opts = [
      target_arn: topic_arn
    ]

    event
    |> SNS.publish(opts)
    |> ExAws.request()
  end
end
