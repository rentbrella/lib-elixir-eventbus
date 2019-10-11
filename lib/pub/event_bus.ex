defmodule Pub do
  @moduledoc """
  Responsible by interact with Rentbrella's Eventbus.

  ## Configuration

  ### Processing functions

  The GenStage present in this application
  uses external functions for process the
  received messages.

  Example bellow configures functions to process
  events `event1`, `event2` and
  `event3`:

  ```elixir
  config :lib_elixir_eventbus,
    callbacks: [
      {"event1",      &MyApp.handle_event1/1},
      {"event2",  &MyApp.handle_event2/1},
      {"event3", &MyApp.handle_3/1}
    ]
  ```

  These functions must be arity 1, and the
  argument passed in each call will be a
  `%Pub.SQSMessage{}` struct.

  Besides this, these functions must return `:ok`
  when received message is successfully processed,
  and `:error` when have a processing error. Any
  different return will cause exceptions and message
  will be returned for processing in future.

  ## Application's architecture

  Modules of this applications is grouped in
  three main roles:

  ### Data structs

  Contains structs which represent data exchanged
  between another modules. Note that structs in this
  group must be created using function `new` of
  corresponding module.

  ### Queue interactions

  Performs all interactions with queue, including
  publications, receivement and acknowledging of
  processed messages.

  Note that functions in this group only implements
  basic functions for pontual queue's interactions.

  For a constant SQS subscription, a GenStage was
  implemented in this library

  ### GenStage modules

  Implements a [GenStage](https://hexdocs.pm/gen_stage/GenStage.html)
  to process SQS messages.

  The _Producer_ will query SQS about new messages,
  _ProducerConsumer_ will filter messages which
  system is not configurated to process, and the
  _Consumer_ will perform a call for process
  function for each message received, passing
  the message processed as argument of this function.

  When callback function returns `:ok`, the Consumer
  will acknowledge message, deleting it, so that it will
  not return for processing.

  On the other hand, if this returns `:error`, the
  Consumer d'nt will acknowledge this, and the message
  will return to queue, to be consumed later.

  More details, see section [Processing functions](#module-processing-functions)
  """

  alias Pub.Queue.Receiver
  alias Pub.Queue.Publisher
  alias Pub.Queue.Acknowledger

  defdelegate publish(event),
    to: Publisher, as: :run
  defdelegate publish(event, topic),
    to: Publisher, as: :run

  defdelegate receive(),
    to: Receiver, as: :run

  defdelegate receive(queue, messages \\ 10),
    to: Receiver, as: :run

  defdelegate acknowledge(event),
    to: Acknowledger, as: :run
end
