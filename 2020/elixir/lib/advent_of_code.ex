defmodule AdventOfCode do
  @callback run(input :: [String.t()]) :: String.t()

  def run do
    Enum.each(list_days(), &run/1)
  end

  def run! do
    Enum.each(list_days(), &run!/1)
  end

  def run(day) do
    module = day_module(day)
    input = read_input(day)

    IO.puts("----- DAY #{day} -----")
    module.run(input)
  end

  def run!(day) do
    expected = read_answer(day)
    answer = run(day)

    if answer != expected do
      raise "Wrong answer; expected #{inspect(expected)}, got #{inspect(answer)}"
    end
  end

  defp list_days do
    Enum.filter(1..30, fn day ->
      module = day_module(day)
      match?({:module, ^module}, Code.ensure_compiled(module))
    end)
  end

  defp day_module(day) do
    String.to_atom("Elixir.AdventOfCode.Day#{day2string(day)}")
  end

  defp read_input(day) do
    ["..", "days", day2string(day), "input.txt"]
    |> Path.join()
    |> File.read!()
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
  end

  defp read_answer(day) do
    ["..", "days", day2string(day), "answer.txt"]
    |> Path.join()
    |> File.read!()
    |> String.trim()
  end

  defp day2string(day) do
    day
    |> Integer.to_string()
    |> String.pad_leading(2, "0")
  end
end
