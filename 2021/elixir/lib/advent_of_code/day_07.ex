defmodule AdventOfCode.Day07 do
  @behaviour AdventOfCode

  def run([input]) do
    initial_positions = input |> String.split(",") |> Enum.map(&String.to_integer/1)
    max = Enum.max(initial_positions)

    answer_a = Enum.map(0..max, &calculate_cost(initial_positions, &1)) |> Enum.min()
    answer_b = Enum.map(0..max, &calculate_expensive_cost(initial_positions, &1)) |> Enum.min()

    {answer_a, answer_b}
  end

  defp calculate_cost(positions, x) do
    Enum.reduce(positions, 0, fn pos, cost ->
      cost + abs(pos - x)
    end)
  end

  defp calculate_expensive_cost(positions, x) do
    Enum.reduce(positions, 0, fn pos, cost ->
      distance = abs(pos - x)
      fuel = trunc(distance * (distance + 1) / 2)
      cost + fuel
    end)
  end
end
