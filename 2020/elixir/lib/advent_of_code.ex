defmodule AdventOfCode do
  @callback run(input :: [String.t()]) :: {String.t(), String.t()}

  def run do
    Enum.each(list_days(), &run/1)
  end

  def run! do
    Enum.each(list_days(), &run!/1)
  end

  def run(day) do
    module = day_module(day)
    input = read_lines(day, :input)

    IO.puts("----- DAY #{day} -----")
    module.run(input)
  end

  def run!(day) do
    expected = day |> read_lines(:answers) |> List.to_tuple()
    answers = run(day)

    if answers != expected do
      raise "Wrong answers; expected #{inspect(expected)}, got #{inspect(answers)}"
    end
  end

  defp list_days do
    Enum.filter(1..25, fn day ->
      module = day_module(day)
      match?({:module, ^module}, Code.ensure_compiled(module))
    end)
  end

  defp day_module(day) do
    String.to_atom("Elixir.AdventOfCode.Day#{day2string(day)}")
  end

  defp read_lines(day, basename) do
    ["..", "days", day2string(day), "#{basename}.txt"]
    |> Path.join()
    |> File.read!()
    |> String.split("\n")
  end

  defp day2string(day) do
    day
    |> Integer.to_string()
    |> String.pad_leading(2, "0")
  end
end
