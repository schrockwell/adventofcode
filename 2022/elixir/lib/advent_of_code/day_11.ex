defmodule AdventOfCode.Day11 do
  @behaviour AdventOfCode

  defmodule Monkey do
    defstruct items: [],
              op: nil,
              counter: 0,
              factor: nil,
              pass_to: nil,
              fail_to: nil
  end

  def run(input) do
    # Forget parsing... let's just use Elixir syntax as the input
    {monkeys, _} = Code.eval_string(input)

    answer_a = run_rounds(monkeys, 20, 3)
    answer_b = run_rounds(monkeys, 10_000, 1)

    {answer_a, answer_b}
  end

  ### High-level execution

  # Iterate over every round
  defp run_rounds(monkeys, round_count, relief) do
    # Convert to modulus lookup tables for part B only
    monkeys = maybe_use_moudulo(monkeys, relief)

    1..round_count
    |> Enum.reduce(monkeys, fn _round, acc ->
      run_round(acc, relief)
    end)
    |> Enum.map(fn {_, m} -> m.counter end)
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> then(fn [a, b] -> a * b end)
  end

  # For part B, convert integers to instead represent items as maps of %{known_factor => remainder}.
  # The effect of each monkey's operation on each factor will be individually tracked per item.
  defp maybe_use_moudulo(monkeys, 1 = _relief) do
    # Pluck out all known factors, for bookkeeping
    known_factors = monkeys |> Map.values() |> Enum.map(& &1.factor)

    Map.new(monkeys, fn {i, m} ->
      items = Enum.map(m.items, fn item -> Map.new(known_factors, &{&1, rem(item, &1)}) end)
      {i, %{m | items: items}}
    end)
  end

  # Part A - represent items as plain integers
  defp maybe_use_moudulo(monkeys, _relief), do: monkeys

  ### Round execution

  # Executes one round of every monkey throwing every item, sequentially
  defp run_round(monkeys, relief) do
    Enum.reduce(
      0..(Enum.count(monkeys) - 1),
      monkeys,
      fn monkey_i, monkeys_acc ->
        throw_all_items(monkeys_acc, monkey_i, relief)
      end
    )
  end

  # Executes one monkey's turn
  defp throw_all_items(monkeys, monkey_i, relief) do
    case monkeys[monkey_i] do
      %Monkey{items: [item | rest]} = monkey ->
        # Pluck the item from this monkey and count it
        this_monkey = %{monkey | items: rest, counter: monkey.counter + 1}

        # Determine the next item worry value
        next_item = apply_op(item, this_monkey.op, relief)

        # Find the destination monkey and catch it
        that_monkey_i = next_monkey_i(next_item, this_monkey)
        that_monkey = catch_item(monkeys[that_monkey_i], next_item)

        # Update the accumulator
        next_monkeys =
          monkeys
          |> Map.put(monkey_i, this_monkey)
          |> Map.put(that_monkey_i, that_monkey)

        # Recurse until there are no more items to throw
        throw_all_items(next_monkeys, monkey_i, relief)

      %Monkey{items: []} ->
        # This monkey has thrown everything, so we're done
        monkeys
    end
  end

  ### Utilities

  # Part A
  defp apply_op(item, op, relief) when is_integer(item) do
    div(op.(item), relief)
  end

  # Part B
  defp apply_op(item, op, 1 = _relief) when is_map(item) do
    Map.new(item, fn {factor, value} ->
      #
      # 🥫🥫🥫 HERE BE THE SECRET SAUCE 🥫🥫🥫
      #
      # We are abusing predetermined knowledge that monkey operations
      # are strictly addition or multiplication, so we can take advantage
      # of the following properties of congruence:
      #
      #   - Compatibility with addition
      #   - Compatibility with scaling
      #
      # https://en.wikipedia.org/wiki/Modular_arithmetic#Properties
      #
      {factor, rem(op.(value), factor)}
    end)
  end

  # Parts A and B
  defp next_monkey_i(item, monkey) do
    if remainder(item, monkey.factor) == 0 do
      monkey.pass_to
    else
      monkey.fail_to
    end
  end

  # Part A
  defp remainder(item, factor) when is_integer(item) do
    rem(item, factor)
  end

  # Part B
  defp remainder(item, factor) when is_map(item) do
    Map.fetch!(item, factor)
  end

  # Catch a new worryful item
  defp catch_item(%Monkey{} = monkey, item) do
    %{monkey | items: monkey.items ++ [item]}
  end
end
