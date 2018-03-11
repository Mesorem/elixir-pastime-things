defmodule WebFlow.HangedReducer do
  @moduledoc false
  alias WebFlow.{HangedReducer, PlayReducer, Guess, SetWord, LogicReducer}

  defstruct [:to_guess, :user_guess, :template, :body_parts]

  def reduce(%PlayReducer{} = play, %SetWord{} = evt) do
    %HangedReducer{to_guess: evt.payload}
    |> create_template
    |> mold
    |> reduce(play)
  end

  def reduce(%PlayReducer{logic: %LogicReducer{correct_guess?: guess}} = play,
    %Guess{payload: letter}) do
      play.hanged
      |> update_template(guess, letter)
      |> mold
      |> update_body_parts(guess)
      |> reduce(play)
  end

  def reduce(%HangedReducer{} = hanged, %PlayReducer{} = play) do
    %PlayReducer{play | hanged: hanged}
  end

  def create_template(%HangedReducer{to_guess: to_guess} = hanged) do
    0
    |> Range.new(String.length(to_guess) - 1)
    |> Enum.map(fn indx -> {indx, "_"} end)
    |> Enum.reduce(%{template: %{}}, fn {indx, underscore}, map ->
      update_in(map[:template], &Map.put(&1, indx, underscore))
     end)
    |> Map.merge(hanged, fn _k, v1, _ -> v1 end)
  end

  def mold(%HangedReducer{template: template} = hanged) do
    molded =
    template
    |> Map.values
    |> Enum.join(" ")
    Map.put(hanged, :user_guess, molded)
  end

  def update_template(%HangedReducer{} = hanged, true, letter) do
    hanged.to_guess
    |> String.codepoints
    |> Enum.reduce({[], 0}, fn char, {list, indx} ->
        if char == letter do
          {[indx | list], indx + 1}
        else
          {list, indx + 1}
        end
      end)
    |> elem(0)
    |> Enum.reduce(hanged, fn index, hanged ->
        %HangedReducer{hanged | template: %{hanged.template | index => letter}}
      end)
  end

  def update_template(%HangedReducer{} = hanged, false, _), do: hanged

  def update_body_parts(%HangedReducer{} = hanged, false) do
    [_part | parts] = hanged.body_parts
    %HangedReducer{hanged | body_parts: parts}
  end

  def update_body_parts(%HangedReducer{} = hanged, true), do: hanged

end
