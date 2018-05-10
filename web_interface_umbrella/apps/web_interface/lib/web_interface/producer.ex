defmodule WebInterface.Producer do
  use GenStage

  def start_link(events) do
    GenStage.start_link(__MODULE__, events)
  end

  def produce(producer, event) do
    GenServer.call(producer, { :produce, event })
  end

  def init(events) do
    { :producer, events }
  end

  def handle_demand(demand, [ event | rem_events ]) when demand > 0 do
    { :noreply, [event], rem_events }
  end

  def handle_demand(demand, events) when demand > 0 do
    { :noreply, [], events }
  end

  def handle_call({ :produce, event }, _from, events) do
    { :reply, :added_to_production, [], [ event | events ] }
  end

  def handle_info(_info, state) do
    { :noreply, state }
  end
end
