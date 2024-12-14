input =
  "01-input.txt"
  |> File.read!()
  |> String.split("\n")
  |> Enum.map(&String.split/1)

first_list = for [first, _] <- input, do: String.to_integer(first)
second_list = for [_, second] <- input, do: String.to_integer(second)

first_list = Enum.sort(first_list)
second_list = Enum.sort(second_list)

part_1_answer =
  first_list
  |> Enum.zip(second_list)
  |> Enum.map(fn {first, second} -> abs(first - second) end)
  |> Enum.sum()

histogram = Enum.frequencies(second_list)

part_2_answer =
  first_list
  |> Enum.map(fn i -> i * Map.get(histogram, i, 0) end)
  |> Enum.sum()

IO.puts("Part 1: #{part_1_answer}")
IO.puts("Part 2: #{part_2_answer}")
