defmodule Pub.Application.Validator do
  @moduledoc false

  @configuration_error """
    You must configure Pub, as bellow:

        config :lib_event_bus,
          callbacks: [
            {"event_name", &function_to_process/1},
            {"another_event", &another_function/1},
          ]
    """

  @required_envvars [
    "AWS_ACCESS_KEY_ID",
    "AWS_SECRET_ACCESS_KEY",
    "AWS_SQS_QUEUE",
    "AWS_SNS_TOPIC_ARN"
  ]

  @environment_error """
    Please, ensure all required envvars is present:
    #{Enum.reduce(@required_envvars, "", fn env, acc ->
      acc <> ~s(\n\t - ) <> env
    end)}
  """

  def validate_environment() do
    missing_env =
      @required_envvars
      |> Enum.reduce([], fn env, acc ->
        if System.get_env(env) |> is_nil() do
          acc ++ [env]
        else
          acc
        end
      end)

    case missing_env do
      [] -> :ok
      _missing -> raise @environment_error
    end
  end

  def validate_configuration([]),
    do: validate_configuration(nil)
  def validate_configuration(nil),
    do: raise @configuration_error
  def validate_configuration(configs)
  when is_list(configs) do
    Enum.map(configs,
      fn
        {event_name, function} ->
          if is_binary(event_name) and is_function(function) do
            :ok
          else
            raise @configuration_error
          end
        _ -> raise @configuration_error
      end
    )
  end
  def validate_configuration(_),
    do: validate_configuration(nil)
end
