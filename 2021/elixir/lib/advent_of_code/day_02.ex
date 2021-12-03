defmodule AdventOfCode.Day02 do
  @behaviour AdventOfCode

  def run(input) do
    {x, y} =
      input
      |> Enum.map(&String.split/1)
      |> Enum.map(fn [dir, x] -> {dir, String.to_integer(x)} end)
      |> Enum.reduce(
        {0, 0},
        fn
          {"forward", i}, {x, y} ->
            {x + i, y}

          {"down", i}, {x, y} ->
            {x, y + i}

          {"up", i}, {x, y} ->
            {x, y - i}
        end
      )

    answer_a = x * y

    {x, y, _a} =
      input
      |> Enum.map(&String.split/1)
      |> Enum.map(fn [dir, x] -> {dir, String.to_integer(x)} end)
      |> Enum.reduce(
        {0, 0, 0},
        fn
          {"forward", i}, {x, y, a} ->
            {x + i, y + a * i, a}

          {"down", i}, {x, y, a} ->
            {x, y, a + i}

          {"up", i}, {x, y, a} ->
            {x, y, a - i}
        end
      )

    answer_b = x * y

    {answer_a, answer_b}
  end
end
