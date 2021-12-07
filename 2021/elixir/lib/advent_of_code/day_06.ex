defmodule AdventOfCode.Day06 do
  @behaviour AdventOfCode

  def run([input]) do
    initial_fish = input |> String.split(",") |> Enum.map(&String.to_integer/1)
    initial_dist = Enum.frequencies(initial_fish)

    answer_a = initial_dist |> iterate(80) |> Map.values() |> Enum.sum()
    answer_b = initial_dist |> iterate(256) |> Map.values() |> Enum.sum()

    {answer_a, answer_b}
  end

  defp iterate(dist, 0), do: dist

  defp iterate(dist, timer) do
    dist
    |> Enum.reduce(%{}, &shift_bucket/2)
    |> iterate(timer - 1)
  end

  defp shift_bucket({0, count}, dist) do
    dist
    |> increment_bucket(6, count)
    |> increment_bucket(8, count)
  end

  defp shift_bucket({timer, count}, dist) do
    increment_bucket(dist, timer - 1, count)
  end

  defp increment_bucket(dist, timer, count) do
    Map.update(dist, timer, count, fn c -> c + count end)
  end
end
