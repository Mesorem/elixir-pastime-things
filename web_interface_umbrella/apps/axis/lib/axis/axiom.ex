defmodule Axis.Axiom do
  @moduledoc """
   The axiom
  """
  use(GenStage)
  require(Logger)

  defstruct [:mod, :data, :intent_mod]

  @doc """
  Starts an axiom

  ## Examples

      iex> Axis.Axiom.start_link(Axis, [], Axis)
      {:ok, link_ref}

  """
  def start_link(module, args, intent_mod) when is_list(args) do
    GenStage.start_link(__MODULE__, {module, args, intent_mod})
  end

  def init({module, args, intent_mod}) do
    {:producer_consumer,
     %__MODULE__{mod: module, data: apply(module, :new, args), intent_mod: intent_mod},
     dispatcher: GenStage.BroadcastDispatcher}
  end

  def handle_events([transformator | _funs], _from, axiom) when is_function(transformator) do
    case transformator.(axiom.data) do
      {new_data, new_transformator} when is_function(new_transformator) ->
        {:noreply, [new_transformator.(new_data)], %__MODULE__{axiom | data: new_data}}

      {new_data, nil} ->
        {:noreply, [], %__MODULE__{axiom | data: new_data}}

      other ->
        Logger.error([
          "Axiom #{IO.inspect(__MODULE__)} error!, Wrong value returned from transformator.",
          "   Transformator: #{IO.inspect(transformator)}\n",
          "   Returned: #{IO.inspect(other)}\n",
          "   Data: #{IO.inspect(axiom.data)}"
        ])

        {:noreply, [], axiom}
    end
  end

  def handle_events([action | _actions], _from, axiom) when is_map(action) do
    Logger.debug([
      "Axiom #{IO.inspect(__MODULE__)} has received an action.",
      "   Action: #{IO.inspect(action)}\n",
      "   Data: #{IO.inspect(axiom.data)}"
    ])

    case apply(axiom.intent_mod, :match, [action]) do
      fun when is_function(fun) ->
        case fun.(axiom.data) do
          {new_data, transformator} when is_function(transformator) ->
            {:noreply, [transformator.(new_data)], %__MODULE__{axiom | data: new_data}}

          {new_data, nil} ->
            {:noreply, [], %__MODULE__{axiom | data: new_data}}

          other ->
            Logger.error([
              "Axiom #{IO.inspect(__MODULE__)} error!, Wrong value returned from transformator.",
              "   Action: #{IO.inspect(action)}\n",
              "   Returned: #{IO.inspect(other)}\n",
              "   Data: #{IO.inspect(axiom.data)}"
            ])

            {:noreply, [], axiom}
        end

      :no_match ->
        Logger.error([
          "Axiom #{IO.inspect(__MODULE__)} error!, action has no match intent module.",
          "   Action: #{IO.inspect(action)}\n",
          "   Data: #{IO.inspect(axiom.data)}"
        ])

        {:noreply, [], axiom}

      other ->
        Logger.error([
          "Axiom #{IO.inspect(__MODULE__)} error!, wrong value returned from intent module match.",
          "   Action: #{IO.inspect(action)}\n",
          "   Returned: #{IO.inspect(other)}\n",
          "   Data: #{IO.inspect(axiom.data)}"
        ])

        {:noreply, [], axiom}
    end
  end

  def handle_events([event | _events], _from, axiom) do
    Logger.info([
      "Axiom #{IO.inspect(__MODULE__)} has received unknown event.",
      "   Event: #{IO.inspect(event)}\n",
      "   Data: #{IO.inspect(axiom.data)}"
    ])

    {:noreply, [], axiom}
  end

  def handle_info(message, axiom) do
    Logger.info([
      "Axiom #{IO.inspect(__MODULE__)} has received unknown message.",
      "   Event: #{IO.inspect(message)}\n",
      "   Data: #{IO.inspect(axiom.data)}"
    ])

    {:noreply, axiom}
  end
end
