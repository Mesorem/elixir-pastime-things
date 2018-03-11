defmodule WebFlow.FlowsSupervisor do
  @moduledoc """
  The root supervisor of the flows.
  """
  use DynamicSupervisor

  @spec start_link(list) :: Supervisor.on_start()
  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, 0, name: __MODULE__)
  end

  @spec start_flow(term, module) :: Supervisor.on_start_child()
  def start_flow(id, reducer) do
    spec = Supervisor.Spec.supervisor(WebFlow.FlowSupervisor, [id, reducer])
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

end
