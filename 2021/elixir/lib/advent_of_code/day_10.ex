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

  # We found a matching closing bracket for the opening bracket on the top of the stack
  defp validate_chunks(<<close::binary-1, remaining::binary>>, [open | next_stack])
       when <<open::binary-1, close::binary-1>> in ~w|() [] {} <>| do
    validate_chunks(remaining, next_stack)
  end

  # We found an opening bracket, so push it onto the stack
  defp validate_chunks(<<open::binary-1, remaining::binary>>, stack) when open in ~w|( [ { <| do
    validate_chunks(remaining, [open | stack])
  end

  # We found a closing bracket that does NOT match the latest opening bracket, so blow up
  defp validate_chunks(<<illegal::binary-1, _remaining::binary>>, _stack) do
    {:error, :illegal_char, illegal}
  end

  # We reached the end of the string with some opening brackets still on the stack
  defp validate_chunks("", [_ | _] = stack) do
    {:error, :incomplete, stack}
  end

  # We reached the end of the line with no brackets remaining - yay!
  # (This never actually gets called with the challenge input, since all lines are invalid)
  defp validate_chunks("", []) do
    :ok
  end

  # Part 1 result
  defp score_illegal_chunks(validations) do
    for {:error, :illegal_char, char} <- validations, reduce: 0 do
      sum -> sum + @illegal_char_points[char]
    end
  end

  # Part 2 result
  defp score_incomplete_chunks(validations) do
    scores =
      for {:error, :incomplete, stack} <- validations do
        for char <- stack, reduce: 0 do
          score -> score * 5 + @incomplete_char_points[char]
        end
      end

    # Pick the median value
    scores
    |> Enum.sort()
    |> Enum.at(trunc((length(scores) - 1) / 2))
  end
end
