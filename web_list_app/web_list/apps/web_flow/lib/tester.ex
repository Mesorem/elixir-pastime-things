defmodule WebFlow.Tester do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, _} = WebFlow.FlowsSupervisor.start_flow("tester", WebFlow.PlayReducer)
    WebFlow.FlowSupervisor.attach_observer("tester", fn play ->
      play.result
    end, {self(), make_ref()})
    {:ok, "tester"}
  end

  def push(event) do
    WebFlow.FlowPusher.sync_push("tester", event)
  end

  def handle_info({:value_change, value, ref}, state) do
    IO.inspect value
    {:noreply, state}
  end

end
