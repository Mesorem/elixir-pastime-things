defmodule CredoTest.OriginSupervisor do
  @moduledoc false

  def start_link do
    children = [child(CredoTest.Distribution.EventManager),
      {CredoTest.Distributor, [1,2,3,4,5,6,7,8,9,10,11,12,13,14]}]
    Supervisor.start_link(children, strategy: :rest_for_one, name: __MODULE__)
  end

  defp child(mod) do
    %{
      id: :evt_manager,
      start: {mod, :start_link, []},
      restart: :transient,
      shutdown: 2000,
      type: :worker,
      module: [mod]
   }
  end

end
