defmodule XYChatTest do
  use ExUnit.Case
  doctest XYChat

  test "greets the world" do
    assert XYChat.hello() == :world
  end
end
