defmodule AdventOfCode.Day09 do
  @behaviour AdventOfCode

  def run(input) do
    moves = parse_moves(input)

    [answer_a, answer_b] =
      for rope_length <- [2, 10] do
        count_tail_visits(build_rope(rope_length), moves)
      end

    {answer_a, answer_b}
  end

  ### Parsing

  # Returns a list of atoms, one per each move
  defp parse_moves(input) do
    input
    |> String.split("\n")
    |> Enum.flat_map(fn line ->
      [move, count] = String.split(line, " ")
      count = String.to_integer(count)

      move =
        case move do
          "R" -> :right
          "L" -> :left
          "D" -> :down
          "U" -> :up
        end

      for _ <- 1..count, do: move
    end)
  end

  # Returns a list of N rope segments, all at the origin {0, 0}
  defp build_rope(length) do
    for _ <- 1..length, do: {0, 0}
  end

  ### Making the moves

  defp count_tail_visits(rope, moves, tail_visits \\ MapSet.new())

  defp count_tail_visits(rope, [move | next_moves], tail_visits) do
    # Pluck off the head and move it one step
    [head | body] = rope
    next_head = shift(head, move)
    initial_acc = [next_head]

    # Move each individual segment based on the position of the segment ahead of it, which has already been moved
    next_rope =
      Enum.reduce(body, initial_acc, fn coord, acc ->
        # Grab the latest-moved segment (one-closer to the head)
        towards_coord = hd(acc)

        if adjacent?(coord, towards_coord) do
          # If still adjacent to the segment, don't move
          [coord | acc]
        else
          # I like to move it, move it
          [move_segment(coord, towards_coord) | acc]
        end
      end)
      # Reverse the list because the head is at the end
      |> Enum.reverse()

    # Accumulate tail visits
    next_tail = Enum.at(next_rope, -1)
    next_tail_visits = MapSet.put(tail_visits, next_tail)

    # visualize(next_rope)

    # Recurse on the remaining moves
    count_tail_visits(next_rope, next_moves, next_tail_visits)
  end

  defp count_tail_visits(_rope, [], tail_visits), do: MapSet.size(tail_visits)

  ### Utilities

  # Cartesian coordinates: up and right are positive, down and left are negative
  defp shift({x, y}, :left), do: {x - 1, y}
  defp shift({x, y}, :right), do: {x + 1, y}
  defp shift({x, y}, :up), do: {x, y + 1}
  defp shift({x, y}, :down), do: {x, y - 1}

  defp adjacent?({x1, y1}, {x2, y2}) do
    abs(x2 - x1) <= 1 and abs(y2 - y1) <= 1
  end

  defp move_segment({x1, y1} = _coord, {x2, y2} = _towards_coord) do
    delta_x =
      cond do
        x2 > x1 -> 1
        x2 == x1 -> 0
        x2 < x1 -> -1
      end

    delta_y =
      cond do
        y2 > y1 -> 1
        y2 == y1 -> 0
        y2 < y1 -> -1
      end

    {x1 + delta_x, y1 + delta_y}
  end

  def visualize(rope) do
    {min_x, max_x} = Enum.map(rope, fn {x, _y} -> x end) |> Enum.min_max()
    {min_y, max_y} = Enum.map(rope, fn {_x, y} -> y end) |> Enum.min_max()

    for y <- max_y..min_y do
      for x <- min_x..max_x do
        case Enum.find(Enum.with_index(rope), fn {c, _i} -> c == {x, y} end) do
          {{_x, _y}, 0} -> IO.write("H")
          {{_x, _y}, i} -> IO.write(to_string(i))
          _ -> IO.write(".")
        end
      end

      IO.puts("")
    end

    IO.puts("")
  end
end
