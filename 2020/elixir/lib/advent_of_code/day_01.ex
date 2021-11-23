defmodule AdventOfCode.Day01 do
  @behaviour AdventOfCode

  def run(input) do
    input = Enum.map(input, &String.to_integer/1)

    # Extremely unoptimized, but it works!
    answer =
      for x <- input, y <- input, x + y == 2020 do
        x * y
      end
      |> hd()

    IO.puts("Answer: #{answer}")

    to_string(answer)
  end
end
