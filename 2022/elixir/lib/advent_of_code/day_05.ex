defmodule AdventOfCode.Day05 do
  @behaviour AdventOfCode

  def run(input) do
    [stacks_input, moves_input] = String.split(input, "\n\n")
    stacks = parse_stacks(stacks_input)
    moves = parse_moves(moves_input)

    [answer_a, answer_b] =
      for crane_model <- 9000..9001 do
        moves
        |> Enum.reduce(stacks, &perform_move(&2, &1, crane_model))
        |> Enum.sort()
        |> Enum.map(fn {_, [top | _]} -> top end)
        |> Enum.join()
      end

    {answer_a, answer_b}
  end

  ### Parsing

  defp parse_stacks(stacks_input) do
    lines = stacks_input |> String.split("\n") |> Enum.slice(0..-2)
    stack_count = trunc((String.length(hd(lines)) + 1) / 4)

    for line <- lines, stack <- 1..stack_count, reduce: %{} do
      stacks ->
        offset = 1 + (stack - 1) * 4
        <<_::binary-size(offset), crate::binary-1, _::binary>> = line

        if crate == " " do
          stacks
        else
          Map.update(stacks, stack, [crate], fn s -> s ++ [crate] end)
        end
    end
  end

  defp parse_moves(moves_input) do
    moves_input
    |> String.split("\n")
    |> Enum.map(fn line ->
      [_, stack, from, to] = Regex.run(~r/move (\d+) from (\d+) to (\d+)/, line)
      %{move: String.to_integer(stack), from: String.to_integer(from), to: String.to_integer(to)}
    end)
  end

  ### Moving

  defp perform_move(stacks, %{move: count, from: from, to: to}, _crane_model = 9000) do
    Enum.reduce(1..count, stacks, fn _, acc ->
      [crate | next_from] = acc[from]
      next_to = [crate | acc[to]]

      acc
      |> Map.put(from, next_from)
      |> Map.put(to, next_to)
    end)
  end

  defp perform_move(stacks, %{move: count, from: from, to: to}, _crane_model = 9001) do
    {moving, next_from} = Enum.split(stacks[from], count)
    next_to = moving ++ stacks[to]

    stacks
    |> Map.put(from, next_from)
    |> Map.put(to, next_to)
  end
end
