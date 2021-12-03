defmodule AdventOfCode.Day03 do
  @behaviour AdventOfCode

  def run(input) do
    gamma_rate = input |> aggregate(:most) |> String.to_integer(2)
    epsilon_rate = input |> aggregate(:least) |> String.to_integer(2)

    answer_a = gamma_rate * epsilon_rate

    o_rating = input |> filter_ratings(:most) |> String.to_integer(2)
    co2_rating = input |> filter_ratings(:least) |> String.to_integer(2)

    answer_b = o_rating * co2_rating

    {answer_a, answer_b}
  end

  defp aggregate(input, popularity) when popularity in [:most, :least] do
    num_entries = length(input)
    majority = num_entries / 2
    num_bits = String.length(hd(input))
    acc = Enum.map(1..num_bits, fn _ -> 0 end)

    input
    |> Enum.map(fn line ->
      line
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.reduce(acc, fn bits, acc ->
      bits
      |> Enum.zip(acc)
      |> Enum.map(&Tuple.sum/1)
    end)
    |> Enum.map(fn count ->
      case popularity do
        :most -> if count >= majority, do: "1", else: "0"
        :least -> if count < majority, do: "1", else: "0"
      end
    end)
    |> Enum.join()
  end

  defp filter_ratings(input, bit \\ 0, popularity)

  defp filter_ratings([result], _bit, _popularity), do: result

  defp filter_ratings(input, bit, popularity) do
    most_common = input |> aggregate(popularity) |> String.at(bit)

    input
    |> Enum.filter(fn i -> i |> String.at(bit) == most_common end)
    |> filter_ratings(bit + 1, popularity)
  end
end
