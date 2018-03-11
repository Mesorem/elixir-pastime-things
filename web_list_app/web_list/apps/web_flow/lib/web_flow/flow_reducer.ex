defmodule WebFlow.FlowReducer do
  @moduledoc """
  This process is a generic flow reducer
  """
  use GenStage
  require Logger
  alias WebFlow.{FlowReducer, FlowPusher}

  defstruct [:state, :save_history, :history, :module]

  @doc """
  Starts the Reducer stage
  ## Options
    * `:history` - sets if the reducer has to keep track of all
    the permutations, `true` to keep track of all changes, and `false` to only
    keep the newest state
  """
  @spec start_link(term, list) :: GenServer.on_start
  def start_link(user_id, opts \\ []) do
    GenStage.start_link(__MODULE__, {user_id, opts}, name: via_tuple(user_id))
  end

  @doc """
  Gets the history
  """
  @spec history(term) :: GenServer.on_call
  def history(id) do
    GenStage.call(via_tuple(id), :history)
  end

  @spec via_tuple(String.t) :: {:via, Registry, {Registry.FlowSupervisor, String.t}}
  def via_tuple(user_id) do
    {:via, Registry, {Registry.FlowReducer, user_id}}
  end

  def init({user_id, opts}) do
    with {:ok, save_history, opts} <- validate_bool(opts, :save_history, false, [true, false]),
         {:ok, module, opts} <- validate_atom(opts, :module),
         :ok <- validate_no_opts_remaining(opts) do
      {:producer_consumer,
        %FlowReducer{
          state: WebFlow.PlayReducer.new([]),
          save_history: save_history,
          history: [],
          module: module
        },
        subscribe_to: [{FlowPusher.via_tuple(user_id), [max_demand: 1]}],
        dispatcher: {GenStage.BroadcastDispatcher, buffer_size: 1}
      }
    else
     {:error, reason} -> {:stop, reason}
    end
  end

  def init(opts) do
    {:stop, "Invalid options #{opts}, must be a history."}
  end

  defp validate_bool(opts, key, default, accepted_values) do
    {value, opts} = Keyword.pop(opts, key, default)

    if value in accepted_values do
      {:ok, value, opts}
    else
      {:error, "No accepted value #{opts} in options"}
    end
  end

  defp validate_atom(opts, key) do
    {value, opts} = Keyword.pop(opts, key)
    if is_atom(value) do
      {:ok, value, opts}
    else
      {:error, "Module<#{value}> is not supportes. It has to be an atom."}
    end
  end

  defp validate_no_opts_remaining(opts) do
    if opts == [] do
      :ok
    else
      {:error, "Unknown options #{inspect opts}"}
    end
  end

  def handle_events(events, _from, %FlowReducer{save_history: true} = state) when is_list(events) do
    updated_state =
    events
    |> Enum.map_reduce(state.state, &reduce_and_map_history(&1, &2))
    |> update_state(state)
    {:noreply, [updated_state.state], updated_state}
  end

  def handle_events(events, _from, %FlowReducer{} = state) when is_list(events) do
    updated_state =
    events
    |> Enum.map(fn(event) -> apply(state.module, :reduce, [state.state, event]) end)
    |> Enum.reduce(state, fn(reduced, state) -> %FlowReducer{state | state: reduced} end)
    {:noreply, [updated_state.state], updated_state}
  end

  defp reduce_and_map_history(event, store) do
    reduced = apply(store.module, :reduce, [store.state, event])
    {{event, reduced}, reduced}
  end

  defp update_state({history, last_mutation}, %FlowReducer{} = state) do
    %FlowReducer{state | history: state.history ++ history, state: last_mutation}
  end

  def handle_call(:history, _from, state) do
    {:reply, {:history, state.history}, [], state}
  end

end
