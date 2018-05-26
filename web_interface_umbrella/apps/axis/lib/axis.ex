defmodule Axis do
  @moduledoc """
  Documentation for Axis.

  Axis is a project wuth the aim to define a completely reactive system
  composed of axioms that change its state as a reaction of outside intents or actions,
  triggering consecutive changes to the axioms linked to it.

  As of now the triggering events are composed of anon functions with injected axiom data

  The axioms that are going to receive outside intents, must have a module
  which converts the intent to the pertinent funcion

  """

  @doc """
  Hello world.

  ## Examples

      iex> Axis.new
      Axis

  """
  def new do
    __MODULE__
  end
end
