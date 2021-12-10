defmodule AdventOfCode.Day10 do
  @behaviour AdventOfCode

  @illegal_char_points %{
    ")" => 3,
    "]" => 57,
    "}" => 1197,
    ">" => 25137
  }

  @incomplete_char_points %{
    "(" => 1,
    "[" => 2,
    "{" => 3,
    "<" => 4
  }

  def run(input) do
    validations = Enum.map(input, &validate_chunks/1)

    answer_a = score_illegal_chunks(validations)
    answer_b = score_incomplete_chunks(validations)

    {answer_a, answer_b}
  end

  defp validate_chunks(line, stack \\ [])

  defp validate_chunks("", []) do
    :ok
  end

  defp validate_chunks("", [_ | _] = stack) do
    {:error, :incomplete, stack}
  end

  defp validate_chunks(")" <> remaining, ["(" | next_stack]) do
    validate_chunks(remaining, next_stack)
  end

  defp validate_chunks("]" <> remaining, ["[" | next_stack]) do
    validate_chunks(remaining, next_stack)
  end

  defp validate_chunks("}" <> remaining, ["{" | next_stack]) do
    validate_chunks(remaining, next_stack)
  end

  defp validate_chunks(">" <> remaining, ["<" | next_stack]) do
    validate_chunks(remaining, next_stack)
  end

  defp validate_chunks(<<char::binary-1, remaining::binary>>, stack) when char in ~w|( [ { <| do
    validate_chunks(remaining, [char | stack])
  end

  defp validate_chunks(<<char::binary-1, _remaining::binary>>, _stack) do
    {:error, :illegal_char, char}
  end

  defp score_illegal_chunks(validations) do
    for {:error, :illegal_char, char} <- validations, reduce: 0 do
      sum -> sum + @illegal_char_points[char]
    end
  end

  defp score_incomplete_chunks(validations) do
    scores =
      for {:error, :incomplete, stack} <- validations do
        for char <- stack, reduce: 0 do
          score -> score * 5 + @incomplete_char_points[char]
        end
      end
      |> Enum.sort()

    Enum.at(scores, trunc((length(scores) - 1) / 2))
  end
end
