defmodule Pub.Queue.Receiver do
  alias ExAws.SQS

  alias Pub.SQSMessage

  @doc "Query SQS for new messages"
  @spec run(binary, Keyword.t()) :: {:ok, list(SQSMessage.t())} | {:error, any}
  def run(queue_name, _opts \\ []) do
    queue_name
    |> SQS.receive_message(max_number_of_messages: 10)
    |> ExAws.request()
    |> unpack_message(queue_name)
  end
  def run(), do: run(System.get_env("AWS_SQS_QUEUE"))

  defp unpack_message({:error, reason}, _),
    do: {:error, reason}
  defp unpack_message({:ok, %{body: %{messages: messages}}}, queue_name) do
    Enum.map(messages, fn message ->
      Pub.SQSMessage.new(message, queue_name)
    end)
  end
end