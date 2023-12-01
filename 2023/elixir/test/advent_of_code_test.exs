defmodule AdventOfCodeTest do
  use ExUnit.Case
  doctest AdventOfCode

  for {day, input_path} <- AdventOfCode.list_inputs() do
    test "solves 2023 day #{day} input #{input_path}" do
      results = AdventOfCode.run(unquote(day), unquote(input_path))

      for {basename, part, answer, solution} <- results do
        assert answer == solution, """
        Expected #{basename} part #{part} to be #{answer}, got #{solution}
        """
      end
    end
  end
end
