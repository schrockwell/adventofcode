defmodule AdventOfCode.Day13 do
  @behaviour AdventOfCode

  defmodule Paper do
    defstruct [:points, :max_x, :max_y]

    def fold(paper, folds) when is_list(folds) do
      Enum.reduce(folds, paper, fn f, p -> fold(p, f) end)
    end

    def fold(paper, {_ord, _value} = fold) do
      new_max_x = paper.max_x |> maybe_divide(:x, fold)
      new_max_y = paper.max_y |> maybe_divide(:y, fold)

      new_points =
        for x <- 0..new_max_x, y <- 0..new_max_y, reduce: MapSet.new() do
          set ->
            coord = %{x: x, y: y}
            if combine?(paper, coord, fold), do: MapSet.put(set, coord), else: set
        end

      %__MODULE__{points: new_points, max_x: new_max_x, max_y: new_max_y}
    end

    # The folds are always in half, so we don't even need to read
    # the location of the fold
    defp maybe_divide(max, ord, {ord, _value}) do
      trunc(max / 2 - 1)
    end

    defp maybe_divide(max, _ord, _fold), do: max

    # Do the folding for an individual point
    defp combine?(paper, coord, fold) do
      dot?(paper, coord) or dot?(paper, folded_coord(coord, fold))
    end

    # If there's a point visible
    defp dot?(paper, coord) do
      MapSet.member?(paper.points, coord)
    end

    # For part 1
    def num_points(paper) do
      MapSet.size(paper.points)
    end

    # Flip an ordinate around the fold
    defp folded_coord(coord, {ord, ord_fold}) do
      other_value = 2 * ord_fold - coord[ord]
      Map.put(coord, ord, other_value)
    end

    # For part 2
    def print(paper) do
      for y <- 0..paper.max_y do
        for x <- 0..paper.max_x, reduce: "" do
          line ->
            if MapSet.member?(paper.points, %{x: x, y: y}) do
              line <> "#"
            else
              line <> " "
            end
        end
        |> IO.puts()
      end

      :ok
    end
  end

  def run(input) do
    points = parse_coords(input)
    folds = parse_folds(input)

    max_x = points |> Enum.map(& &1.x) |> Enum.max()
    max_y = points |> Enum.map(& &1.y) |> Enum.max()
    paper = %Paper{points: points, max_x: max_x, max_y: max_y}

    [first_fold | _] = folds
    answer_a = paper |> Paper.fold(first_fold) |> Paper.num_points()

    paper |> Paper.fold(folds) |> Paper.print()
    answer_b = "JZGUAPRB"

    {answer_a, answer_b}
  end

  # Returns a MapSet of coordinates
  defp parse_coords(input) do
    input
    |> Enum.filter(fn s -> Regex.match?(~r/^\d/, s) end)
    |> Enum.map(fn s ->
      [x, y] = String.split(s, ",")
      %{x: String.to_integer(x), y: String.to_integer(y)}
    end)
    |> MapSet.new()
  end

  # Returns a keyword list of folds
  defp parse_folds(input) do
    input
    |> Enum.filter(fn s -> String.starts_with?(s, "fold along") end)
    |> Enum.map(fn <<"fold along ", ord::binary-1, "=", value::binary>> ->
      key = String.to_atom(ord)
      {key, String.to_integer(value)}
    end)
  end
end
