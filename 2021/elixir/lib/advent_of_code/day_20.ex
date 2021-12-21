defmodule AdventOfCode.Day20 do
  @behaviour AdventOfCode

  defmodule Image do
    defstruct [:points, :width, :height, :algorithm, :background]
  end

  def run([algorithm, "" | image]) do
    image = parse_image(image, algorithm)

    answer_a =
      image
      |> enhance()
      |> enhance()
      |> count_lit()

    answer_b =
      1..50
      |> Enum.reduce(image, fn _, i -> enhance(i) end)
      |> count_lit()

    {answer_a, answer_b}
  end

  # Returns an %Image{}
  defp parse_image(lines, algorithm) do
    points =
      lines
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, y} ->
        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.map(fn
          {".", x} -> {{x, y}, "0"}
          {"#", x} -> {{x, y}, "1"}
        end)
      end)
      |> Map.new()

    width = 1 + (points |> Map.keys() |> Enum.map(fn {x, _y} -> x end) |> Enum.max())
    height = 1 + (points |> Map.keys() |> Enum.map(fn {_x, y} -> y end) |> Enum.max())

    algorithm =
      algorithm
      |> String.replace(".", "0")
      |> String.replace("#", "1")

    %Image{points: points, width: width, height: height, algorithm: algorithm, background: "0"}
  end

  # Samples 9 pixels of an input image and returns the resulting output pixel
  defp sample(image, {x, y}) do
    index =
      for yp <- (y - 1)..(y + 1), xp <- (x - 1)..(x + 1) do
        Map.get(image.points, {xp, yp}, image.background)
      end
      |> Enum.join()
      |> String.to_integer(2)

    String.at(image.algorithm, index)
  end

  defp enhance(image) do
    # The core image always expands by 2 in each direction
    new_width = image.width + 2
    new_height = image.height + 2

    # The background MIGHT alternate between dark and light
    new_background =
      if image.background == "0" do
        String.at(image.algorithm, 0)
      else
        String.at(image.algorithm, -1)
      end

    # Do the mapping
    new_points =
      for x <- 0..(new_width - 1), y <- 0..(new_height - 1), reduce: %{} do
        points ->
          Map.put(points, {x, y}, sample(image, {x - 1, y - 1}))
      end

    %Image{
      width: new_width,
      height: new_height,
      points: new_points,
      algorithm: image.algorithm,
      background: new_background
    }
  end

  # Answer calculation
  defp count_lit(image) do
    image.points |> Map.values() |> Enum.count(&(&1 == "1"))
  end

  # For debugging purposes
  defp display(image) do
    for y <- 0..(image.height - 1) do
      0..(image.width - 1)
      |> Enum.map(fn x -> Map.fetch!(image.points, {x, y}) end)
      |> Enum.map(fn
        "0" -> "."
        "1" -> "#"
      end)
      |> Enum.join()
      |> IO.puts()
    end

    image
  end
end
