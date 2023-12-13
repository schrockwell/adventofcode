defmodule AdventOfCode.Day12 do
  @behaviour AdventOfCode

  # Part 1
  def run(_basename, 1, input) do
    input
    |> parse_input()
    |> Enum.map(fn {str, groups} -> count_groups("", str, groups) end)
    |> Enum.sum()
  end

  # Part 2
  def run(_basename, 2, _input) do
    0
  end

  defp count_groups(str, "?" <> rest, groups) do
    count1 = count_groups(str <> ".", rest, groups)
    count2 = count_groups(str <> "#", rest, groups)
    count1 + count2
  end

  defp count_groups(str, <<char::binary-1, rest::binary>>, groups) do
    count_groups(str <> char, rest, groups)
  end

  defp count_groups(str, "", groups) do
    str
    |> String.trim(".")
    |> String.codepoints()
    |> Enum.chunk_by(&(&1 == "#"))
    |> Enum.map(&Enum.count/1)
    |> Enum.take_every(2)
    |> case do
      ^groups -> 1
      _ -> 0
    end
  end

  # Try both possibilities
  # defp take("?" <> rest, groups, acc) do
  #   count1 = take("." <> rest, groups, 0)
  #   count2 = take("#" <> rest, groups, 0)
  #   acc + count1 + count2
  # end

  # # Success
  # defp take("", [], acc), do: acc

  # # Failure: umatched groups
  # defp take("", [_ | _], _acc), do: 0

  # # Failure: still some string left
  # defp take(str, [], _acc) when str != "", do: 0

  # # Swallow up "."s
  # defp take("." <> _rest = str, groups, acc) do
  #   IO.puts("swallowing .s")
  #   str = String.trim_leading(str, ".")
  #   take(str, groups, acc)
  # end

  # # Greedily match groups
  # defp take("#" <> _rest = str, [group | groups], acc) do
  #   next_str = String.trim_leading(str, "#")

  #   if String.length(str) - String.length(next_str) == group do
  #     # Cool, we found a group!
  #     IO.puts("#{str}: found a group of #{group}")
  #     take(next_str, groups, acc + 1)
  #   else
  #     # Failure
  #     IO.puts("#{str}: failed to find a group of #{group}")
  #     0
  #   end
  # end

  defp parse_input(input) do
    for line <- input do
      [str, groups] = String.split(line, " ")
      groups = groups |> String.split(",") |> Enum.map(&String.to_integer/1)
      {str, groups}
    end
  end
end
