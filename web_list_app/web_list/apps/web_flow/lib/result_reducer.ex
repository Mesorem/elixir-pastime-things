defmodule WebFlow.ResultReducer do
  @moduledoc false
  alias WebFlow.{LogicReducer, PlayReducer}

  def reduce(%PlayReducer{logic: %LogicReducer{correct_guess?: true}} = play) do
    result = if String.contains?(play.hanged.user_guess, "_") do
      {:correct, play.hanged.user_guess, play.hanged.body_parts}
    else
      {:correct, :win, play.hanged.user_guess, play.hanged.body_parts}
    end
    %PlayReducer{play | result: result}
  end

  def reduce(%PlayReducer{logic: %LogicReducer{correct_guess?: false}} = play) do
    result = case play.hanged.body_parts do
      [] ->
        {:wrong, :lost, play.hanged.user_guess, :dead}
      parts ->
        {:wring, play.hanged.user_guess, parts}
    end
    %PlayReducer{play | result: result}
  end

end
