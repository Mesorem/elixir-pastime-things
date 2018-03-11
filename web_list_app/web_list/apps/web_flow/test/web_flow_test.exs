defmodule WebFlowTest do
  use ExUnit.Case
  doctest WebFlow

  test "greets the world" do
    assert WebFlow.hello() == :world
  end
end
