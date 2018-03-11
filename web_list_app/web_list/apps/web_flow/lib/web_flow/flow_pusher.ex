defmodule WebFlow.FlowPusher do
  @moduledoc """
  This process pushes events to the reducer
  """
    use GenStage
    require Logger

    @doc """
    Start the GenStage under the id
    """
    @spec start_link(term):: GenServer.on_start()
    def start_link(id) do
      GenStage.start_link(__MODULE__, :ok, name: via_tuple(id))
    end

    @doc """
    Synchornic event pushing
    """
    @spec sync_push(term, term) :: :pushed
    def sync_push(id, event) do
      GenStage.call(via_tuple(id), {:event, event})
    end

    @doc """
    Async event pushing
    """
    @spec async_push(term, term) :: :ok
    def async_push(id, event) do
      GenStage.cast(via_tuple(id), {:event, event})
    end

    @doc """
    The via_tuple tuple to get the via name of the genstage
    """
    @spec via_tuple(term) :: {:via, Registry, {Registry.FlowPusher, term}}
    def via_tuple(id) do
      {:via, Registry, {Registry.FlowPusher, id}}
    end

    def init(_args) do
      {:producer, []}
    end

    def handle_demand(demand, state) when demand > 0 do
      {:noreply, [], state}
    end

    def handle_call({:event, event}, _from, state) do
      {:reply, :pushed, [event], state}
    end

    def handle_cast({:event, event}, _from, state) do
      {:noreply, [event], state}
    end

    def handle_info(info, state) do
      Logger.info "FlowPusher received unexpected message: #{info}."
      {:noreply, state}
    end

end
