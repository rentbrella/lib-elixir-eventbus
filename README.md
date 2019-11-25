# Pub

Performs interactions with EventBus

## Initial creation

This library is created with the following command:

```bash
mix new --module Pub --sup --app lib_event_bus lib-eventbus
```

## Installation

Add in your `mix.exs`:

```elixir
  defp deps do
    [
      # another packages here ...
      {:lib_event_bus, "0.1.0", organization: "rentbrella"}
    ]
  end
```

## Configuration

### Environment variables

This library depends of the following environment variables to work correctly:

* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`
* `AWS_SQS_QUEUE`
* `AWS_SNS_TOPIC_ARN`

### Callback functions

Configure callback functions according bellow:

```elixir
config :lib_elixir_eventbus,
  callbacks: [
    {"event1",      &MyCoolModule.my_func1/1},
    {"event2",  &MyCoolModule.my_func2/1},
    {"event3", &MyCoolModule.my_func3/1}
  ]
```

These functions will be called whenever a new message is arrived by SQS. The argument of this function will be a struct `%SQSMessage{}` representing the received message.

Note that is possible set up different functions for different events.

## Usage

### Publishing a message

```elixir
alias Pub
alias EventBus.Event

{:ok, event} = Event.new("event1", %{"user_id" => 1})

EventBus.publish(event)
```

### Receiving a message

```elixir
alias Pub

EventBus.get_message()
```