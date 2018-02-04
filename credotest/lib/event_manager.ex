defmodule CredoTest.EventManager do
  @moduledoc """
  The event manager of this project
  """

  def start_link() do
    DynamicSupervisor.start_link(strategy: :one_for_one, name: :evt_manager)
  end

  def notify(evt) do
    for {_, pid, _, _} <- DynamicSupervisor.which_children(:evt_manager) do
      GenServer.cast(pid, evt)
    end
    :ok
  end

  def call(evt) do
    :evt_manager
    |> DynamicSupervisor.which_children()
    |> Enum.map(&Task.async(GenServer, :call, [elem(&1, 1), evt]))
    |> Enum.map(&Task.await(&1))
  end

 # testing this method. are all the ids in a DynamicSupervisor :undefined?
  def terminate_handler(id) do
    for {a, pid, _, _} <- DynamicSupervisor.which_children(:evt_manager), a == id  do
      DynamicSupervisor.terminate_children(:evt_manager, pid)
    end
  end

  def terminate_all_handlers() do
    for {_id, pid, _, _} <- DynamicSupervisor.which_children(:evt_manager) do
      DynamicSupervisor.terminate_children(:evt_manager, pid)
    end
  end

end
