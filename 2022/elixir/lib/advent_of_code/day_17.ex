defmodule AdventOfCode.Day17 do
  @behaviour AdventOfCode

  @hbar :hbar
  @cross :cross
  @el :el
  @vbar :vbar
  @square :square

  @floor_y -1
  @left_x -1
  @right_x 7

  defmodule State do
    defstruct jet_i: 0,
              jets: [],
              map: MapSet.new(),
              shape: nil,
              shape_coord: nil,
              count: 0
  end

  def run(input) do
    state = %State{
      jet_i: 0,
      jets: parse_jet_pattern(input),
      map: MapSet.new(),
      shape: @hbar,
      shape_coord: {2, 3},
      count: 0
    }

    answer_a =
      state
      |> do_the_thing(2022)
      |> Map.fetch!(:map)
      |> Enum.map(fn {_x, y} -> y end)
      |> Enum.max()
      |> then(fn max -> max + 1 end)

    {answer_a, :skip}
  end

  ### Parsing

  defp parse_jet_pattern(line) do
    line
    |> String.graphemes()
    |> Enum.map(fn
      "<" -> :left
      ">" -> :right
    end)
  end

  ### Shape collision detection

  # X###
  defp shape_touches?(map, @hbar, :left, {x, y}), do: occupied?(map, {x - 1, y})
  defp shape_touches?(map, @hbar, :right, {x, y}), do: occupied?(map, {x + 4, y})

  defp shape_touches?(map, @hbar, :down, {x, y}),
    do: any_occupied?(map, [{x, y - 1}, {x + 1, y - 1}, {x + 2, y - 1}, {x + 3, y - 1}])

  # .#.
  # ###
  # X#.
  defp shape_touches?(map, @cross, :left, {x, y}),
    do: any_occupied?(map, [{x, y}, {x - 1, y + 1}, {x, y + 2}])

  defp shape_touches?(map, @cross, :right, {x, y}),
    do: any_occupied?(map, [{x + 2, y}, {x + 3, y + 1}, {x + 2, y + 2}])

  defp shape_touches?(map, @cross, :down, {x, y}),
    do: any_occupied?(map, [{x, y}, {x + 1, y - 1}, {x + 2, y}])

  # ..#
  # ..#
  # X##
  defp shape_touches?(map, @el, :left, {x, y}),
    do: any_occupied?(map, [{x - 1, y}, {x + 1, y + 1}, {x + 1, y + 2}])

  defp shape_touches?(map, @el, :right, {x, y}),
    do: any_occupied?(map, [{x + 3, y}, {x + 3, y + 1}, {x + 3, y + 2}])

  defp shape_touches?(map, @el, :down, {x, y}),
    do: any_occupied?(map, [{x, y - 1}, {x + 1, y - 1}, {x + 2, y - 1}])

  # #
  # #
  # #
  # X
  defp shape_touches?(map, @vbar, :left, {x, y}),
    do: any_occupied?(map, [{x - 1, y}, {x - 1, y + 1}, {x - 1, y + 2}, {x - 1, y + 3}])

  defp shape_touches?(map, @vbar, :right, {x, y}),
    do: any_occupied?(map, [{x + 1, y}, {x + 1, y + 1}, {x + 1, y + 2}, {x + 1, y + 3}])

  defp shape_touches?(map, @vbar, :down, {x, y}), do: occupied?(map, {x, y - 1})

  # ##
  # X#
  defp shape_touches?(map, @square, :left, {x, y}),
    do: any_occupied?(map, [{x - 1, y}, {x - 1, y + 1}])

  defp shape_touches?(map, @square, :right, {x, y}),
    do: any_occupied?(map, [{x + 2, y}, {x + 2, y + 1}])

  defp shape_touches?(map, @square, :down, {x, y}),
    do: any_occupied?(map, [{x, y - 1}, {x + 1, y - 1}])

  defp any_occupied?(map, coords), do: Enum.any?(coords, &occupied?(map, &1))

  defp occupied?(_map, {@left_x, _}), do: true
  defp occupied?(_map, {@right_x, _}), do: true
  defp occupied?(_map, {_, @floor_y}), do: true
  defp occupied?(map, coord), do: MapSet.member?(map, coord)

  ### Shape persistence

  defp commit_shape(state, @hbar, {x, y}) do
    commit_coords(state, [{x, y}, {x + 1, y}, {x + 2, y}, {x + 3, y}])
  end

  defp commit_shape(state, @cross, {x, y}) do
    commit_coords(state, [{x + 1, y}, {x, y + 1}, {x + 1, y + 1}, {x + 2, y + 1}, {x + 1, y + 2}])
  end

  defp commit_shape(state, @el, {x, y}) do
    commit_coords(state, [{x, y}, {x + 1, y}, {x + 2, y}, {x + 2, y + 1}, {x + 2, y + 2}])
  end

  defp commit_shape(state, @vbar, {x, y}) do
    commit_coords(state, [{x, y}, {x, y + 1}, {x, y + 2}, {x, y + 3}])
  end

  defp commit_shape(state, @square, {x, y}) do
    commit_coords(state, [{x, y}, {x, y + 1}, {x + 1, y}, {x + 1, y + 1}])
  end

  defp commit_coords(state, coords) do
    coords = MapSet.new(coords)

    # Ensure we are not overlapping anything
    unless MapSet.intersection(state.map, coords) |> Enum.empty?() do
      raise "oh no"
    end

    next_map = MapSet.union(state.map, coords)
    %{state | map: next_map}
  end

  ### Doing the thing

  defp do_the_thing(state, count) do
    finish_count = count + 1

    state
    |> blow()
    |> fall()
    |> case do
      %{count: ^finish_count} -> state
      state -> do_the_thing(state, count)
    end
  end

  defp blow(state) do
    jet_direction = Enum.at(state.jets, state.jet_i)
    state = %{state | jet_i: rem(state.jet_i + 1, length(state.jets))}
    # IO.write("Trying to blow #{jet_direction}...")

    if shape_touches?(state.map, state.shape, jet_direction, state.shape_coord) do
      # IO.puts("blocked")
      state
    else
      # IO.puts("success")
      next_coord = shift(state.shape_coord, jet_direction)
      %{state | shape_coord: next_coord}
    end
  end

  defp fall(state) do
    # IO.write("Trying to fall...")

    if shape_touches?(state.map, state.shape, :down, state.shape_coord) do
      # IO.puts("Stopped at #{inspect(state.shape_coord)}")

      state
      |> commit_shape(state.shape, state.shape_coord)
      |> drop_next_shape()
    else
      next_coord = shift(state.shape_coord, :down)
      # IO.puts("falling to #{inspect(next_coord)}")
      %{state | shape_coord: next_coord}
    end
  end

  defp drop_next_shape(state) do
    next_shape =
      case state.shape do
        @hbar -> @cross
        @cross -> @el
        @el -> @vbar
        @vbar -> @square
        @square -> @hbar
      end

    next_coord = starting_position(state.map)
    # IO.puts("Dropping #{next_shape} at #{inspect(next_coord)}")
    %{state | shape: next_shape, shape_coord: next_coord, count: state.count + 1}
  end

  defp starting_position(map) do
    # x = 2, y = 3 above above the previous top
    max_y = map |> Enum.map(fn {_x, y} -> y end) |> Enum.max(fn -> @floor_y end)
    {2, max_y + 4}
  end

  defp shift({x, y}, :left), do: {x - 1, y}
  defp shift({x, y}, :right), do: {x + 1, y}
  defp shift({x, y}, :down), do: {x, y - 1}
end
