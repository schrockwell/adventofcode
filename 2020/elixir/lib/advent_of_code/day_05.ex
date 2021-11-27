defmodule AdventOfCode.Day05 do
  @behaviour AdventOfCode

  def run(input) do
    seat_ids =
      input
      |> Enum.map(&split_word/1)
      |> Enum.map(fn {fb, lr} ->
        {decode(fb, "F", "B"), decode(lr, "L", "R")}
      end)
      |> Enum.map(fn {row, col} -> row * 8 + col end)
      |> Enum.sort()

    answer_a = Enum.max(seat_ids)

    {lower, _higher} =
      Enum.slice(seat_ids, 0..-2)
      |> Enum.zip(Enum.slice(seat_ids, 1..-1))
      |> Enum.find(fn {id1, id2} -> id2 - id1 == 2 end)

    answer_b = lower + 1

    {answer_a, to_string(answer_b)}
  end

  defp split_word(<<row::binary-7, col::binary-3>>) do
    {row, col}
  end

  defp decode(string, zero, one) do
    string
    |> String.replace(zero, "0")
    |> String.replace(one, "1")
    |> String.to_integer(2)
  end
end
