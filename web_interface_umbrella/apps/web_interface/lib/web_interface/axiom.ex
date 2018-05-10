defmodule WebInterface.Axiom do
  use GenStage

  alias WebInterface.Axiom
  alias Diet.Stepper

  defstruct [:module, :data, :runner]

  def start_link(module, args) do
    GenStage.start_link(__MODULE__, {module, args})
  end

  def init({module, args}) do
    {:producer_consumer, %Axiom{module: module, data: apply(module, :new, args), runner: Stepper.new(module, nil)}, dispatcher: GenStage.BroadcastDispatcher}
  end

  def handle_events([event | _t], _from, state) do
    { { :done, new_data }, _runner } = Stepper.run(state.runner, { :rle, event, state.data })
    { :noreply, [ new_data ], %Axiom{ state | data: new_data } }
  end

  def handle_info(_info, state) do
    { :noreply, [], state }
  end
end
