defmodule WebInterface.Consumer do
  use GenStage

  def start_links(producer, fun) do
    {:ok, pid} = GenStage.start_link(__MODULE__, fun)
    GenStage.sync_subscribe(pid, to: producer, max_demand: 1)
  end

  def init(fun) do
    { :consumer, fun }
  end

  def handle_events([event | []], _from, fun) do
    fun.(event)
    { :noreply, [], fun }
  end

  def handle_events(_events, _from, fun) do
    { :noreply, [], fun }
  end

  def handle_info(_info, state) do
    { :noreply, state
  end

end
