defmodule AdventOfCode.Day14 do
  @behaviour AdventOfCode

  @directions %{
    0 => :north,
    1 => :west,
    2 => :south,
    3 => :east
  }

  # Part 1
  def run(_basename, 1, input) do
    input
    |> parse_input()
    |> cycle(1)
    |> draw_map()
    |> score()
  end

  # Part 2
  def run(_basename, 2, input) do
    input
    |> parse_input()
    |> cycle(1_000_000_000)
    |> draw_map()
    |> score()
  end

  defp cycle(problem, cycles) do
    new_map =
      for i <- 0..(cycles - 1),
          dir = Map.get(@directions, rem(i, 4)),
          x <- 0..(dim(problem, dir) - 1),
          reduce: problem.map do
        acc ->
          changes =
            problem.map
            |> take(dir, x)
            |> roll(dir)

          Map.merge(acc, changes)
      end

    %{problem | map: new_map}
  end

  # Parse the input, for god's sake
  defp parse_input(input) do
    width = input |> hd() |> String.length()
    height = input |> length()

    map =
      for {line, y} <- Enum.with_index(input) do
        for {char, x} <- Enum.with_index(String.codepoints(line)) do
          {{x, y}, char}
        end
      end
      |> List.flatten()
      |> Map.new()

    %{
      map: map,
      width: width,
      height: height
    }
  end

  # Getters
  defp take(map, dir, col) when dir in [:north, :south] do
    Enum.filter(map, fn {{x, _}, _} -> x == col end)
  end

  defp take(map, dir, row) when dir in [:west, :east] do
    Enum.filter(map, fn {{_, y}, _} -> y == row end)
  end

  defp roll(line, dir) do
    sorter =
      if dir in [:north, :west] do
        fn {_, val} -> val == "." end
      else
        fn {_, val} -> val != "." end
      end

    line
    |> Enum.sort()
    |> Enum.chunk_by(fn {_, val} -> val == "#" end)
    |> Enum.reject(fn chunk ->
      chunk |> hd() |> elem(1) == "#"
    end)
    |> Enum.map(fn chunk ->
      y_offset = chunk |> Enum.map(fn {{_, y}, _} -> y end) |> Enum.min()

      chunk
      |> Enum.sort_by(sorter)
      |> Enum.with_index()
      |> Enum.map(fn {{{x, _}, val}, new_y} ->
        {{x, new_y + y_offset}, val}
      end)
    end)
    |> List.flatten()
    |> Map.new()
  end

  defp score(problem) do
    problem.map
    |> Enum.map(fn
      {{_, y}, "O"} -> problem.height - y
      _ -> 0
    end)
    |> Enum.sum()
  end

  defp draw_map(problem) do
    for y <- 0..(problem.height - 1) do
      for x <- 0..(problem.width - 1) do
        IO.write(Map.get(problem.map, {x, y}))
      end

      IO.puts("")
    end

    problem
  end

  defp dim(problem, dir) when dir in [:north, :south], do: problem.width
  defp dim(problem, dir) when dir in [:west, :east], do: problem.height
end
