defmodule AdventOfCode.Day01 do
  @behaviour AdventOfCode

  def run("example1.txt", _, input) do
    sum_a(input)
  end

  def run("example2.txt", _, input) do
    sum_b(input)
  end

  def run("input.txt", 1, input) do
    sum_a(input)
  end

  def run("input.txt", 2, input) do
    sum_b(input)
  end

  defp sum_a(input) do
    input
    |> Enum.map(fn line ->
      first_digit(line) * 10 + first_digit(String.reverse(line))
    end)
    |> Enum.sum()
  end

  defp sum_b(input) do
    input
    |> Enum.map(fn line ->
      first_digit_alpha(line) * 10 + first_digit_alpha_rev(String.reverse(line))
    end)
    |> Enum.sum()
  end

  defp first_digit("1" <> _rest), do: 1
  defp first_digit("2" <> _rest), do: 2
  defp first_digit("3" <> _rest), do: 3
  defp first_digit("4" <> _rest), do: 4
  defp first_digit("5" <> _rest), do: 5
  defp first_digit("6" <> _rest), do: 6
  defp first_digit("7" <> _rest), do: 7
  defp first_digit("8" <> _rest), do: 8
  defp first_digit("9" <> _rest), do: 9
  defp first_digit(<<_char>> <> rest), do: first_digit(rest)

  defp first_digit_alpha("one" <> _rest), do: 1
  defp first_digit_alpha("two" <> _rest), do: 2
  defp first_digit_alpha("three" <> _rest), do: 3
  defp first_digit_alpha("four" <> _rest), do: 4
  defp first_digit_alpha("five" <> _rest), do: 5
  defp first_digit_alpha("six" <> _rest), do: 6
  defp first_digit_alpha("seven" <> _rest), do: 7
  defp first_digit_alpha("eight" <> _rest), do: 8
  defp first_digit_alpha("nine" <> _rest), do: 9
  defp first_digit_alpha("1" <> _rest), do: 1
  defp first_digit_alpha("2" <> _rest), do: 2
  defp first_digit_alpha("3" <> _rest), do: 3
  defp first_digit_alpha("4" <> _rest), do: 4
  defp first_digit_alpha("5" <> _rest), do: 5
  defp first_digit_alpha("6" <> _rest), do: 6
  defp first_digit_alpha("7" <> _rest), do: 7
  defp first_digit_alpha("8" <> _rest), do: 8
  defp first_digit_alpha("9" <> _rest), do: 9
  defp first_digit_alpha(<<_char, rest::binary>>), do: first_digit_alpha(rest)

  defp first_digit_alpha_rev("eno" <> _rest), do: 1
  defp first_digit_alpha_rev("owt" <> _rest), do: 2
  defp first_digit_alpha_rev("eerht" <> _rest), do: 3
  defp first_digit_alpha_rev("ruof" <> _rest), do: 4
  defp first_digit_alpha_rev("evif" <> _rest), do: 5
  defp first_digit_alpha_rev("xis" <> _rest), do: 6
  defp first_digit_alpha_rev("neves" <> _rest), do: 7
  defp first_digit_alpha_rev("thgie" <> _rest), do: 8
  defp first_digit_alpha_rev("enin" <> _rest), do: 9
  defp first_digit_alpha_rev("1" <> _rest), do: 1
  defp first_digit_alpha_rev("2" <> _rest), do: 2
  defp first_digit_alpha_rev("3" <> _rest), do: 3
  defp first_digit_alpha_rev("4" <> _rest), do: 4
  defp first_digit_alpha_rev("5" <> _rest), do: 5
  defp first_digit_alpha_rev("6" <> _rest), do: 6
  defp first_digit_alpha_rev("7" <> _rest), do: 7
  defp first_digit_alpha_rev("8" <> _rest), do: 8
  defp first_digit_alpha_rev("9" <> _rest), do: 9
  defp first_digit_alpha_rev(<<_char, rest::binary>>), do: first_digit_alpha_rev(rest)
end
