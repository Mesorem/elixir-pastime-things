defmodule CredoTest.EventHandler.Logger do
  @moduledoc """
  The event handler that uses the logger
  """
  use GenServer

  require Logger

  def start_link, do: GenServer.start_link(__MODULE__, [], [])

  def init(_), do: {:ok, :nostate}

  def handle_cast(:distribution_complete, state) do
    Logger.info :distribution_complete
    {:noreply, state}
  end

  def handle_cast(:distribution_ready, state) do
    {:noreply, state}
  end

  def handle_cast(_message, state), do: {:noreply, state}

  def handle_call(_message, _from, state), do: {:reply, {:reply, :noready}, state}

  def handle_info(_info, state), do: {:noreply, state}
end
