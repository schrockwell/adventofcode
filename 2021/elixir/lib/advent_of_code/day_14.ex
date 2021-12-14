defmodule AdventOfCode.Day14 do
  @behaviour AdventOfCode

  def run(input) do
    [template, _ | rules] = input

    # We will need this first character for the final answer tally
    <<first_char::binary-1, _::binary>> = template
    pair_counts = initial_pair_counts(template)
    rules = parse_rules(rules)

    answer_a = pair_counts |> step(rules, 10) |> count_chars(first_char) |> to_answer()
    answer_b = pair_counts |> step(rules, 40) |> count_chars(first_char) |> to_answer()

    {answer_a, answer_b}
  end

  # Returns a map of %{pair => inserted_char}
  defp parse_rules(rules) do
    rules
    |> Enum.map(fn <<pair::binary-2, " -> ", insertion::binary-1>> ->
      {pair, insertion}
    end)
    |> Map.new()
  end

  # Returns a map of pair counts for the startingn template
  defp initial_pair_counts(template) do
    template
    |> to_pairs()
    |> Enum.reduce(%{}, fn p, pc -> inc_map(pc, p, 1) end)
  end

  # Returns a list of pairs for the initial template
  defp to_pairs(template) do
    left = template |> String.graphemes() |> Enum.slice(0..-2)
    right = template |> String.graphemes() |> Enum.slice(1..-1)

    left
    |> Enum.zip(right)
    |> Enum.map(fn {l, r} -> l <> r end)
  end

  # Convert x source pairs to 2x destination pairs with the new inserted char
  defp update_pair_count(pair_count, <<left::binary-1, right::binary-1>>, to_insert, count) do
    first_new_pair = left <> to_insert
    second_new_pair = to_insert <> right

    pair_count
    |> inc_map(first_new_pair, count)
    |> inc_map(second_new_pair, count)
  end

  # Generic map incrementor which is useful many places
  defp inc_map(map, key, value) do
    Map.update(map, key, value, &(&1 + value))
  end

  # Main iterative loop
  defp step(pair_counts, rules, steps)

  defp step(pair_counts, _rules, 0), do: pair_counts

  defp step(pair_counts, rules, steps) do
    for {pair, count} <- pair_counts, reduce: %{} do
      pc -> update_pair_count(pc, pair, rules[pair], count)
    end
    |> step(rules, steps - 1)
  end

  # Returns a map of the character counts; we need to know the first char since we are
  # only using one char per pair to determine the counts, and there is always one more
  # char than there are pairs in the polymer string (e.g. if the string is length 7,
  # there are 6 pairs, so there is 1 char of missing information)
  defp count_chars(pair_counts, first_char) do
    for {<<_dont_care::binary-1, char::binary-1>>, count} <- pair_counts, reduce: %{} do
      cc ->
        inc_map(cc, char, count)
    end
    |> inc_map(first_char, 1)
  end

  # Convert the char counts to the final answer
  defp to_answer(char_counts) do
    {min, max} = char_counts |> Map.values() |> Enum.min_max()
    max - min
  end
end
