defmodule CredoTest.Distributor do
@moduledoc """
This process distributes a elements of a list to the
recivers asking for it
"""
  use GenServer

  def start_link(list) do
    GenServer.start_link(__MODULE__, list, name: __MODULE__)
  end

  def distribute() do
    GenServer.call(__MODULE__, :distribute)
  end

  def recover(element) do
    GenServer.cast(__MODULE__, {:recover, element})
  end

  def init(list) do
    {:ok, %{bag: list, distributed: []}}
  end

  def handle_call(:distribute, _from, dist) do
    rand_elem = Enum.random(dist.bag)
    dist
    |> Map.update(:bag, [], &List.delete(&1, rand_elem))
    |> Map.update(:distributed, [], &List.insert_at(&1, 0, rand_elem))
    |> reply(rand_elem)
  end

  def handle_cast({:recover, elem}, dist) do
    dist
    |> Map.update(:distributed, [], &List.delete(&1, elem))
    |> Map.update(:bag, [], &List.insert_at(&1, 0, elem))
    |> noreply()
  end

  defp reply(state, reply), do: {:reply, reply, state}
  defp noreply(state), do: {:noreply, state}

end
