defmodule WebFlow.FlowObserver do
  @moduledoc """
   A process that observes a part of the state of the reducer, and informs
   the registered processes if it detects a change in it.
  """
  use GenStage
  alias WebFlow.{FlowObserver, FlowReducer}

  defstruct [:current_value, :selector, :reg_proc]

  @spec start_link(term, fun, tuple) :: GenServer.on_start()
  def start_link(reducer_id, selector, proc_to_register) do
    GenStage.start_link(__MODULE__, {reducer_id, selector, proc_to_register}, [])
  end

  # validate args
  def init({reducer_id, selector, proc_to_register}) do
    {
      :consumer,
      %FlowObserver{selector: selector, reg_proc: proc_to_register},
      subscribe_to: [{FlowReducer.via_tuple(reducer_id), [max_demand: 1]}]
    }
  end

  # refractor this into a pipe
  def handle_events([event], _from,
    %FlowObserver{selector: selector, reg_proc: {pid, ref}} = state) do
      new_value = apply(selector, [event])
      current_value = state.current_value
      new_value = if new_value != current_value do
        send(pid, {:value_change, new_value, ref})
        new_value
      else
        current_value
      end
      new_state = %FlowObserver{state | current_value: new_value}
      {:noreply, [], new_state}
  end

end
