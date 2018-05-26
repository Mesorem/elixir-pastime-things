defmodule AxisTest do
  use ExUnit.Case
  doctest Axis

  test "greets the world" do
    assert Axis.new() == Axis
  end

  test "start an axiom, the module must have a new function" do
    assert {:ok, _axiom_ref} = Axis.Axiom.start_link(Axis, [], Axis)
  end
end
