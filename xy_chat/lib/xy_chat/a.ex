defmodule A do
  use GenStage

  def test(hello, hello) do
    :equals
  end

  def test(hello, perlo) do
    :not_equals
  end

  def start_link(mode, subject) do
    GenStage.start_link(__MODULE__, {mode, subject})
  end

  def init(args = {:in, subject}) do
    # GenStage.sync_subscribe(subject, to: self())
    {:producer, args}
  end

  def init(args = {:out, subject}) do
    # GenStage.sync_subscribe(self(), to: subject)
    {:consumer, args}
  end

  def handle_demand(demand, counter) when demand > 0 do
    # If the counter is 3 and we ask for 2 items, we will
    # emit the items 3 and 4, and set the state to 5.
    events = Enum.to_list(counter..(counter + demand - 1))
    {:noreply, events, counter + demand}
  end
end
