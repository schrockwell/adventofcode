defmodule AOC2024.Day02 do
  @reports "02-input.txt"
           |> File.read!()
           |> String.split("\n")
           |> Enum.map(fn line -> line |> String.split(" ") |> Enum.map(&String.to_integer/1) end)

  @asc_diffs MapSet.new([1, 2, 3])
  @desc_diffs MapSet.new([-3, -2, -1])

  defp safe?(report) do
    diffs =
      report
      |> Enum.zip(Enum.drop(report, 1))
      |> Enum.map(fn {a, b} -> a - b end)

    all_asc = Enum.all?(diffs, fn diff -> MapSet.member?(@asc_diffs, diff) end)
    all_desc = Enum.all?(diffs, fn diff -> MapSet.member?(@desc_diffs, diff) end)

    all_asc || all_desc
  end

  def part1 do
    @reports
    |> Enum.filter(&safe?/1)
    |> Enum.count()
  end

  def part2 do
    @reports
    |> Enum.filter(fn report ->
      other_reports =
        for i <- 0..(length(report) - 1) do
          List.delete_at(report, i)
        end

      Enum.any?([report | other_reports], &safe?/1)
    end)
    |> Enum.count()
  end
end

IO.puts("Part 1: #{AOC2024.Day02.part1()}")
IO.puts("Part 2: #{AOC2024.Day02.part2()}")
