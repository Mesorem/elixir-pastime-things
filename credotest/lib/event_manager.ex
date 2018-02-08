defmodule CredoTest.EventManager do
  @moduledoc """
  The event manager of this project
  """
  @spec start_link() :: {:ok, pid} | term
  def start_link do
    DynamicSupervisor.start_link(strategy: :one_for_one, name: :evt_manager)
  end

  @spec attach_handler(Module) :: term
  def attach_handler(mod) do
    DynamicSupervisor.start_child(:evt_manager, child(mod))
  end

  defp child(mod) do
    %{
      id: make_ref(),
      start: {mod, :start_link, []},
      restart: :transient,
      shutdown: 2000,
      type: :worker,
      module: [mod]
   }
  end

  @spec notify(tuple) :: list
  def notify(evt) do
    for {_, pid, _, _} <- DynamicSupervisor.which_children(:evt_manager) do
      GenServer.cast(pid, evt)
    end
  end

  @spec call(tuple) :: list
  def call(evt) do
    :evt_manager
    |> DynamicSupervisor.which_children()
    |> Enum.map(&Task.async(GenServer, :call, [elem(&1, 1), evt]))
    |> Enum.map(&Task.await(&1))
  end

 # testing this method. are all the ids in a DynamicSupervisor :undefined?
  @spec terminate_handler(term) :: list
  def terminate_handler(id) do
    for {a, pid, _, _} <- DynamicSupervisor.which_children(:evt_manager),
      a == id  do
      DynamicSupervisor.terminate_child(:evt_manager, pid)
    end
  end

  @spec terminate_all_handlers() :: list
  def terminate_all_handlers do
    for {_id, pid, _, _} <- DynamicSupervisor.which_children(:evt_manager) do
      DynamicSupervisor.terminate_child(:evt_manager, pid)
    end
  end

end
