defmodule WebFlow.PlayReducer do

  alias WebFlow.{PlayReducer, LogicReducer, ResultReducer, HangedReducer, Guess, SetWord}

  defstruct [logic: %LogicReducer{}, hanged: %HangedReducer{}, result: nil]

  def new(_args) do
    %PlayReducer{hanged: %HangedReducer{body_parts: ["l-arm", "r-arm", "l-leg", "r-leg", "head"]}}
  end

  def reduce(%PlayReducer{} = play, %Guess{} = evt) do
    play
    |> LogicReducer.reduce(evt)
    |> HangedReducer.reduce(evt)
    |> ResultReducer.reduce()
  end

  def reduce(%PlayReducer{} = play, %SetWord{} = evt) do
    play
    |> HangedReducer.reduce(evt)
  end

end
