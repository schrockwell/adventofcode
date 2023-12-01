defmodule AdventOfCode do
  @callback run(basename :: String, part :: non_neg_integer(), input :: String.t()) :: any()

  def run(day, input_path) do
    {input, answers} = read_input_file!(input_path)

    answers
    |> Enum.with_index()
    |> Enum.map(fn {answer, part} ->
      basename = Path.basename(input_path)
      solution = to_string(day_module(day).run(basename, part + 1, input))
      {basename, part, answer, solution}
    end)
  end

  def list_days do
    Enum.filter(1..25, fn day ->
      module = day_module(day)
      match?({:module, ^module}, Code.ensure_compiled(module))
    end)
  end

  def list_inputs do
    days =
      Enum.filter(1..25, fn day ->
        module = day_module(day)
        match?({:module, ^module}, Code.ensure_compiled(module))
      end)

    Enum.flat_map(days, fn day ->
      "priv/days/#{format_day(day)}/*.txt"
      |> Path.wildcard()
      |> Enum.map(fn path -> {day, path} end)
    end)
  end

  defp day_module(day) do
    String.to_atom("Elixir.AdventOfCode.Day#{format_day(day)}")
  end

  defp read_input_file!(path) do
    {answers, ["---" | input]} =
      path
      |> File.read!()
      |> String.split("\n", trim: true)
      |> Enum.split_while(&(&1 != "---"))

    {input, answers}
  end

  defp format_day(day) do
    day
    |> Integer.to_string()
    |> String.pad_leading(2, "0")
  end
end
