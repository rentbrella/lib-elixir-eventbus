defmodule EventBus.Queue.Acknowledger do
  alias ExAws.SQS

  alias EventBus.SQSMessage

  @doc "Deletes a message from SQS after processing it"
  @spec run(SQSMessage.t()) :: {:ok, map} | {:error, any}
  def run(%SQSMessage{queue_name: queue, receipt_handle: receipt_handle}) do
    queue
    |> SQS.delete_message(receipt_handle)
    |> ExAws.request()
  end
end
