defmodule AdventOfCode.Day08 do
  @behaviour AdventOfCode

  def run(input) do
    codes = Enum.map(input, &parse_code/1)

    answer_a =
      codes
      |> Enum.map(&count_easy_digits/1)
      |> Enum.sum()

    answer_b =
      codes
      |> Enum.map(&solve/1)
      |> Enum.map(&decode_digits/1)
      |> Enum.sum()

    {answer_a, answer_b}
  end

  defp parse_code(line) do
    tokens = String.split(line)

    patterns =
      tokens
      |> Enum.slice(0..9)
      |> Enum.map(&MapSet.new(String.graphemes(&1)))

    digits =
      tokens
      |> Enum.slice(11..14)
      |> Enum.map(&MapSet.new(String.graphemes(&1)))

    %{
      patterns: patterns,
      digits: digits,
      signal_dist: signal_dist(patterns),
      solved_signals: %{},
      solved_patterns: %{}
    }
  end

  # Part 1 solution
  defp count_easy_digits(%{digits: digits}) do
    Enum.count(digits, &(MapSet.size(&1) in [2, 3, 4, 7]))
  end

  # Returns a map of the signal frequencies for a list of pattern MapSets
  defp signal_dist(patterns) do
    patterns
    |> Enum.map(&MapSet.to_list/1)
    |> List.flatten()
    |> Enum.join()
    |> String.graphemes()
    |> Enum.frequencies()
  end

  # Solve all patterns and signals (ORDER MATTERS!)
  defp solve(code) do
    code
    |> solve_signal("e")
    |> solve_signal("b")
    |> solve_signal("f")
    |> solve_pattern(1)
    |> solve_pattern(4)
    |> solve_pattern(7)
    |> solve_pattern(8)
    |> solve_pattern(2)
    |> solve_signal("a")
    |> solve_signal("c")
    |> solve_signal("d")
    |> solve_signal("g")
    |> solve_pattern(0)
    |> solve_pattern(3)
    |> solve_pattern(5)
    |> solve_pattern(6)
    |> solve_pattern(9)
  end

  # Once all the digits are known, this converts the code to an integer
  defp decode_digits(code) do
    code.digits
    |> Enum.map(&decode_digit(code, &1))
    |> Enum.join()
    |> String.to_integer()
  end

  defp decode_digit(code, pattern) do
    [{digit, ^pattern}] = code.solved_patterns |> Enum.filter(fn {_d, p} -> p == pattern end)
    digit
  end

  ######## SIGNAL SOLUTIONS ########

  defp solve_signal(code, "e") do
    # Signal E appears exactly 4 times
    [{displayed, 4}] = Enum.filter(code.signal_dist, fn {_, count} -> count == 4 end)
    put_signal(code, displayed, "e")
  end

  defp solve_signal(code, "b") do
    # Signal B appears exactly 6 times
    [{displayed, 6}] = Enum.filter(code.signal_dist, fn {_, count} -> count == 6 end)
    put_signal(code, displayed, "b")
  end

  defp solve_signal(code, "f") do
    # Signal F appears exactly 9 times
    [{displayed, 9}] = Enum.filter(code.signal_dist, fn {_, count} -> count == 9 end)
    put_signal(code, displayed, "f")
  end

  defp solve_signal(code, "a") do
    # Signal A is whatever is in 7 but not 1
    [displayed] =
      MapSet.difference(code.solved_patterns[7], code.solved_patterns[1]) |> MapSet.to_list()

    put_signal(code, displayed, "a")
  end

  defp solve_signal(code, "c") do
    # Signal C shows up 3 times in the remaining digits 0, 3, 5, 6, 9
    put_signal(code, find_unsolved_signal_with_count(code, 3), "c")
  end

  defp solve_signal(code, "d") do
    # Signal D shows up 4 times in the remaining digits 0, 3, 5, 6, 9
    put_signal(code, find_unsolved_signal_with_count(code, 4), "d")
  end

  defp solve_signal(code, "g") do
    # Signal G shows up 5 times in the remaining digits 0, 3, 5, 6, 9
    put_signal(code, find_unsolved_signal_with_count(code, 5), "g")
  end

  defp find_unsolved_signal_with_count(code, count) do
    [{displayed, ^count}] =
      code
      |> unsolved_patterns()
      |> signal_dist()
      |> Enum.filter(fn {_, c} -> c == count end)
      |> Enum.reject(fn {displayed_signal, _} ->
        displayed_signal in Map.keys(code.solved_signals)
      end)

    displayed
  end

  defp put_signal(code, displayed, actual) do
    %{code | solved_signals: Map.put(code.solved_signals, displayed, actual)}
  end

  ######## PATTERN SOLUTIONS ########

  defp solve_pattern(code, 1) do
    # The only pattern with 2 segments lit
    [pattern] = Enum.filter(code.patterns, &(MapSet.size(&1) == 2))
    put_pattern(code, 1, pattern)
  end

  defp solve_pattern(code, 4) do
    # The only pattern with 4 segments lit
    [pattern] = Enum.filter(code.patterns, &(MapSet.size(&1) == 4))
    put_pattern(code, 4, pattern)
  end

  defp solve_pattern(code, 7) do
    # The only pattern with 3 segments lit
    [pattern] = Enum.filter(code.patterns, &(MapSet.size(&1) == 3))
    put_pattern(code, 7, pattern)
  end

  defp solve_pattern(code, 8) do
    # The only pattern with 7 segments lit
    [pattern] = Enum.filter(code.patterns, &(MapSet.size(&1) == 7))
    put_pattern(code, 8, pattern)
  end

  defp solve_pattern(code, 2) do
    # Pattern 2 has E, but not B nor F
    [pattern] =
      Enum.filter(code.patterns, fn pattern ->
        pattern_contains?(code, pattern, ["e"]) and
          not pattern_contains?(code, pattern, ["b", "f"])
      end)

    put_pattern(code, 2, pattern)
  end

  defp solve_pattern(code, 0) do
    put_pattern(code, 0, displayed_pattern(code, ["a", "b", "c", "e", "f", "g"]))
  end

  defp solve_pattern(code, 3) do
    put_pattern(code, 3, displayed_pattern(code, ["a", "c", "d", "f", "g"]))
  end

  defp solve_pattern(code, 5) do
    put_pattern(code, 5, displayed_pattern(code, ["a", "b", "d", "f", "g"]))
  end

  defp solve_pattern(code, 6) do
    put_pattern(code, 6, displayed_pattern(code, ["a", "b", "d", "e", "f", "g"]))
  end

  defp solve_pattern(code, 9) do
    put_pattern(code, 9, displayed_pattern(code, ["a", "b", "c", "d", "f", "g"]))
  end

  defp put_pattern(code, digit, pattern) do
    %{code | solved_patterns: Map.put(code.solved_patterns, digit, pattern)}
  end

  defp pattern_contains?(code, pattern, real_signals) do
    Enum.all?(real_signals, fn real_signal ->
      displayed_signal = code.solved_signals |> invert() |> Map.fetch!(real_signal)
      MapSet.member?(pattern, displayed_signal)
    end)
  end

  defp unsolved_patterns(code) do
    Enum.filter(code.patterns, fn pattern ->
      code.solved_patterns
      |> Map.values()
      |> Enum.find(&(&1 == pattern))
      |> is_nil()
    end)
  end

  defp displayed_pattern(code, real) do
    real
    |> Enum.map(fn s -> code.solved_signals |> invert() |> Map.fetch!(s) end)
    |> MapSet.new()
  end

  ######## UTILITIES ########

  defp invert(code) do
    code |> Enum.map(fn {k, v} -> {v, k} end) |> Map.new()
  end
end
