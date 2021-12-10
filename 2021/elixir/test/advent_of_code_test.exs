defmodule AdventOfCodeTest do
  use ExUnit.Case
  doctest AdventOfCode

  for day <- AdventOfCode.list_days() do
    test "solves 2021 day #{day}" do
      AdventOfCode.run!(unquote(day))
    end
  end
end
