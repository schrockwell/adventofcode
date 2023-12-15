defmodule AdventOfCode.Day14 do
  @behaviour AdventOfCode

  # Part 1
  def run(_basename, 1, input) do
    problem = parse_input(input)

    new_map =
      for x <- 0..(problem.width - 1), reduce: problem.map do
        acc ->
          changes =
            problem.map
            |> column(x)
            |> roll()

          Map.merge(acc, changes)
      end

    problem =
      %{problem | map: new_map}
      |> draw_map()

    score(problem)
  end

  # Part 2
  def run(_basename, 2, _input) do
    0
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
  defp column(map, col) do
    Enum.filter(map, fn {{x, _}, _} -> x == col end)
  end

  defp row(map, row) do
    Enum.filter(map, fn {{_, y}, _} -> y == row end)
  end

  defp roll(line) do
    line
    |> Enum.sort()
    |> Enum.chunk_by(fn {_, val} -> val == "#" end)
    |> Enum.reject(fn chunk ->
      chunk |> hd() |> elem(1) == "#"
    end)
    |> Enum.map(fn chunk ->
      y_offset = chunk |> Enum.map(fn {{_, y}, _} -> y end) |> Enum.min()

      chunk
      |> Enum.sort_by(fn {_, val} -> val == "." end)
      |> Enum.with_index()
      |> Enum.map(fn {{{x, _}, val}, new_y} ->
        {{x, new_y + y_offset}, val}
      end)
    end)
    |> List.flatten()
    |> Map.new()
    |> IO.inspect(label: "roll line")
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
end
