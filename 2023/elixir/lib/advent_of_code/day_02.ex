defmodule AdventOfCode.Day02 do
  @behaviour AdventOfCode

  def run(_, 1, input) do
    max_cubes = %{"red" => 12, "green" => 13, "blue" => 14}

    input
    |> Enum.map(&part_1_game_score(&1, max_cubes))
    |> Enum.sum()
  end

  def run(_, 2, input) do
    input
    |> Enum.map(&part_2_game_power(&1))
    |> Enum.sum()
  end

  defp parse_draws(string) do
    string
    |> String.split("; ")
    |> Enum.flat_map(&String.split(&1, ", "))
    |> Enum.map(fn draw ->
      [num, color] = String.split(draw, " ")
      {String.to_integer(num), color}
    end)
  end

  defp part_1_game_score("Game " <> line, max_cubes) do
    [game_num, rest] = String.split(line, ": ")

    rest
    |> parse_draws()
    |> Enum.any?(fn {num, color} ->
      num > max_cubes[color]
    end)
    |> if do
      0
    else
      String.to_integer(game_num)
    end
  end

  defp part_2_game_power("Game " <> line) do
    [_game_num, rest] = String.split(line, ": ")

    rest
    |> parse_draws()
    |> Enum.reduce(%{"red" => 0, "green" => 0, "blue" => 0}, fn {num, color}, acc ->
      Map.update!(acc, color, &max(&1, num))
    end)
    |> Map.values()
    |> Enum.product()
  end
end
