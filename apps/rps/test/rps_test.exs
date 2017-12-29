defmodule RPSTest do
  use ExUnit.Case
  doctest RPS

  test "greets the world" do
    assert RPS.hello() == :world
  end
end
