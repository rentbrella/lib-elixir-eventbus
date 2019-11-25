
defmodule EventBus.SQSMessageTest do
  use ExUnit.Case

  defp valid_event_message() do
    %{
      attributes: [],
      body: ~s({
        "Type":"Notification",
        "MessageId":"e55f00bf-8414-55ab-9476-55ec1673c81f",
        "TopicArn":"arn:aws:sns:us-east-1:302136685096:qas",
        "Message":"{\\"event\\":\\"user_blocked\\",\\"payload\\":{\\"user_id\\":1},\\"version\\":\\"2019-05-11\\"}",
        "Timestamp":"2019-05-13T15:41:27.767Z",
        "SignatureVersion":"1",
        "SigningCertURL":"https://sns.us-east-1.amazonaws.com/SimpleNotificationService-6aad65c2f9911b05cd53efda11f913f9.pem",
        "UnsubscribeURL":"https://sns.us-east-1.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-east-1:302136685096:qas:2d2ec485-8a2b-44b4-9522-c1c4522c7329"
      }),
      md5_of_body: "0f990edb5c24c478561b7ac6aaa817e6",
      message_attributes: [],
      message_id: "088dd8e1-d5d0-4580-bbaa-ecc6c9733fc0",
      receipt_handle: "my_receipt_handle"
    }
  end

  defp invalid_event_message() do
    %{
      attributes: [],
      body: ~s("{
        "Type":"Notification",
        "MessageId":"e55f00bf-8414-55ab-9476-55ec1673c81f",
        "TopicArn":"arn:aws:sns:us-east-1:302136685096:qas",
        "Message":"{}",
        "Timestamp":"2019-05-13T15:41:27.767Z",
        "SignatureVersion":"1",
        "SigningCertURL":"https://sns.us-east-1.amazonaws.com/SimpleNotificationService-6aad65c2f9911b05cd53efda11f913f9.pem",
        "UnsubscribeURL":"https://sns.us-east-1.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-east-1:302136685096:qas:2d2ec485-8a2b-44b4-9522-c1c4522c7329"}"
      ),
      md5_of_body: "0f990edb5c24c478561b7ac6aaa817e6",
      message_attributes: [],
      message_id: "088dd8e1-d5d0-4580-bbaa-ecc6c9733fc0",
      receipt_handle: "my_receipt_handle"
    }
  end

  alias EventBus.SQSMessage

  doctest EventBus.SQSMessage

  describe "SQSMessage.new/1" do
    test "sets has_valid_event? as true when have valid event" do
      assert %SQSMessage{has_valid_event?: true} = SQSMessage.new(valid_event_message(), "fake")
    end

    test "sets has_valid_event? as false when have no valid event" do
      assert %SQSMessage{has_valid_event?: false} = SQSMessage.new(invalid_event_message(), "fake")
    end

    test "sets receipt_handle" do
      message = SQSMessage.new(valid_event_message(), "fake")

      assert message.receipt_handle == valid_event_message().receipt_handle
    end
  end
end
