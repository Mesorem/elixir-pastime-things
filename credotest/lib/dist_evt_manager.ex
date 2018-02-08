defmodule CredoTest.Distribution.EventManager do
  @moduledoc false

  alias CredoTest.EventManager

  def start_link do
    {:ok, sup_pid} = EventManager.start_link()
    EventManager.attach_handler(CredoTest.EventHandler.Logger)
    {:ok, sup_pid}
  end

  def distribution_completed do
    EventManager.notify(:distribution_complete)
  end

end
