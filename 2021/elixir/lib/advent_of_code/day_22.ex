defmodule AdventOfCode.Day22 do
  @behaviour AdventOfCode

  def run(input) do
    steps = parse_steps(input)

    answer_a = steps |> Enum.filter(&initialization?/1) |> initialize() |> MapSet.size()

    {answer_a, "todo"}
  end

  defp parse_steps(input) do
    regex = ~r/(on|off) x=(-?\d+)\.\.(-?\d+),y=(-?\d+)\.\.(-?\d+),z=(-?\d+)\.\.(-?\d+)/

    input
    |> Enum.map(&Regex.run(regex, &1))
    |> Enum.map(fn
      [_, on_off, x1, x2, y1, y2, z1, z2] ->
        {String.to_atom(on_off),
         %{
           x: String.to_integer(x1)..String.to_integer(x2),
           y: String.to_integer(y1)..String.to_integer(y2),
           z: String.to_integer(z1)..String.to_integer(z2)
         }}
    end)
  end

  defp initialization?({_on_off, cuboid}) do
    Enum.all?([cuboid.x, cuboid.y, cuboid.z], fn range ->
      range.first >= -50 and range.last <= 50
    end)
  end

  defp initialize(steps) do
    for {direction, cuboid} <- steps,
        x <- cuboid.x,
        y <- cuboid.y,
        z <- cuboid.z,
        reduce: MapSet.new() do
      set ->
        if direction == :on do
          MapSet.put(set, {x, y, z})
        else
          MapSet.delete(set, {x, y, z})
        end
    end
  end
end
