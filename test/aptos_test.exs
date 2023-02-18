defmodule AptosTest do
  use ExUnit.Case
  doctest Aptos

  test "greets the world" do
    assert Aptos.hello() == :world
  end
end
