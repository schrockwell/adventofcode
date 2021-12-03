defmodule AdventOfCodeTest do
  use ExUnit.Case
  doctest AdventOfCode

  test "solves all problems" do
    assert AdventOfCode.run!()
  end
end
