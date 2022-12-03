defmodule AdventOfCode.Day01 do
  @behaviour AdventOfCode

  def run(input) do
    sorted_elves =
      input
      |> String.split("\n")
      |> Enum.chunk_by(&(&1 == ""))
      |> Enum.reject(&(&1 == [""]))
      |> Enum.map(fn elf_calories ->
        elf_calories
        |> Enum.map(&String.to_integer/1)
        |> Enum.sum()
      end)
      |> Enum.sort(:desc)

    answer_a = hd(sorted_elves)
    answer_b = sorted_elves |> Enum.take(3) |> Enum.sum()

    {answer_a, answer_b}
  end
end
