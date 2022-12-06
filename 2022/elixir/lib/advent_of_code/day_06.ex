defmodule AdventOfCode.Day06 do
  @behaviour AdventOfCode

  def run(signal) do
    signal = String.graphemes(signal)

    [answer_a, answer_b] =
      for length <- [4, 14] do
        find_marker(signal, length)
      end

    {answer_a, answer_b}
  end

  defp find_marker(chars, length, index \\ 0) do
    marker = Enum.take(chars, length)

    if Enum.uniq(marker) == marker do
      index + length
    else
      find_marker(tl(chars), length, index + 1)
    end
  end
end
