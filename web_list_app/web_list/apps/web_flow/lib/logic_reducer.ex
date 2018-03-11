defmodule WebFlow.LogicReducer do
  @moduledoc false
  alias WebFlow.{PlayReducer, Guess, LogicReducer}

  defstruct [correct_guess?: false]

  def reduce(%PlayReducer{} = play, %Guess{} = evt) do
    correct_guess? = String.contains?(play.hanged.to_guess, evt.payload)
    %PlayReducer{play | logic: %LogicReducer{play.logic | correct_guess?: correct_guess?}}
  end

end
