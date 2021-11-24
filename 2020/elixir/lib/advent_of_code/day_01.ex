defmodule AdventOfCode.Day01 do
  @behaviour AdventOfCode

  def run(input) do
    input = Enum.map(input, &String.to_integer/1)

    # Extremely unoptimized, but it works!
    answer_a =
      for x <- input, y <- input, x + y == 2020 do
        x * y
      end
      |> hd()

    answer_b =
      for x <- input, y <- input, z <- input, x + y + z == 2020 do
        x * y * z
      end
      |> hd()

    IO.puts("Answer A: #{answer_a}")
    IO.puts("Answer B: #{answer_b}")

    {to_string(answer_a), to_string(answer_b)}
  end
end
