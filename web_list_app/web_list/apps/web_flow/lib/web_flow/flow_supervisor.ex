defmodule WebFlow.FlowSupervisor do
  @moduledoc """
  The Supervisor that supervises the genstages that compose a flow
  """
  use Supervisor
  alias WebFlow.{FlowPusher, FlowReducer, FlowObserver}

  @doc """
  Start the flow supervisor which starts the pusher, the reducer and the
  observers supervisor
  """
  @spec start_link(term, atom) :: Supervisor.on_start()
  def start_link(user_id, reducer_module) do
    case Supervisor.start_link(__MODULE__, {user_id, reducer_module}, name: via_tuple(user_id)) do
      {:error, {:already_started, pid}} ->
        {:ok, pid}
      {:ok, pid} ->
        {:ok, pid}
      other ->
        other
    end
  end

  @doc """
  Attachs an observer to the flow<id> where the selector
  selects the part of data to observe, and the alarm_proc is the
  {pid, ref} to inform of a data update.
  """
  @spec attach_observer(String.t, fun, Module) :: Supervisor.on_start_child()
  def attach_observer(id, selector, alarm_proc) do
    spec = Supervisor.Spec.worker(FlowObserver, [id, selector, alarm_proc])
    DynamicSupervisor.start_child(via_tuple_observer_sup(id), spec)
  end

  @doc """
  Deletes the observer of the flow<id>
  """
  @spec detach_observer(term) :: :ok | {:error, term}
  def detach_observer(_id) do

  end

  @doc """
  The via tuple for the flow supervisor
  """
  @spec via_tuple(String.t) :: {:via, Registry, {Registry.FlowSupervisor, String.t}}
  def via_tuple(user_id) do
    {:via, Registry, {Registry.FlowSupervisor, user_id}}
  end

  def init({id, reducer_module}) do
    children = [
      Supervisor.Spec.worker(FlowPusher, [id]),
      Supervisor.Spec.worker(FlowReducer, [id, [module: reducer_module]]),
      Supervisor.Spec.supervisor(DynamicSupervisor, [[strategy: :one_for_one, name: via_tuple_observer_sup(id)]])
    ]
    Supervisor.init(children, strategy: :rest_for_one)
  end

  defp via_tuple_observer_sup(id) do
    {:via, Registry, {Registry.FlowObserverSup, id}}
  end

end
