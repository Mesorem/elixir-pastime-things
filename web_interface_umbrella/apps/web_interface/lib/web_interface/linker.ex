defmodule WebInterface.Linker do

  @doc """
  Links two processes(genStage)
  """
  @spec link(consumer :: pid(), producer :: pid()) :: term()
  def link(process1, process2) do
    Task.start_link(fn ->
      {:ok, _link1} = GenStage.sync_subscribe(process1, to: process2, max_demand: 1)
      {:ok, _link2} = GenStage.sync_subscribe(process2, to: process1, max_demand: 1)
      :linked
    end)
  end

end
