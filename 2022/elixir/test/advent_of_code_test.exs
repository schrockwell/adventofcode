defmodule AdventOfCodeTest do
  use ExUnit.Case
  doctest AdventOfCode

  for day <- AdventOfCode.list_days() do
    test "solves 2022 day #{day} example" do
      assert {:ok, _, _} = AdventOfCode.run!(unquote(day), :example)
    end

    test "solves 2022 day #{day}" do
      assert {:ok, _, _} = AdventOfCode.run!(unquote(day))
    end
  end
end
