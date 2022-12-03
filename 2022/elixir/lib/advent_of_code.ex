defmodule AdventOfCode do
  @callback run(input :: [String.t()]) :: {term, term}

  def run do
    Enum.each(list_days(), &run/1)
  end

  def run! do
    Enum.each(list_days(), &run!/1)
  end

  def run(day) do
    module = day_module(day)
    input = read_file(day, :input)

    IO.puts("----- DAY #{day} -----")
    module.run(input)
  end

  def run!(day) do
    expected = day |> read_file(:answers) |> String.split("\n")
    {answer_a, answer_b} = run(day)

    IO.puts("Answer A: #{answer_a}")
    IO.puts("Answer B: #{answer_b}")

    if answer_a != :skip and to_string(answer_a) != Enum.at(expected, 0) do
      raise "Wrong answer for A; expected #{inspect(Enum.at(expected, 0))}, got #{inspect(answer_a)}"
    end

    if answer_b != :skip and to_string(answer_b) != Enum.at(expected, 1) do
      raise "Wrong answer for B; expected #{inspect(Enum.at(expected, 1))}, got #{inspect(answer_b)}"
    end
  end

  def list_days do
    Enum.filter(1..25, fn day ->
      module = day_module(day)
      match?({:module, ^module}, Code.ensure_compiled(module))
    end)
  end

  defp day_module(day) do
    String.to_atom("Elixir.AdventOfCode.Day#{format_day(day)}")
  end

  defp read_file(day, basename) do
    ["priv", "days", format_day(day), "#{basename}.txt"]
    |> Path.join()
    |> File.read!()
  end

  defp format_day(day) do
    day
    |> Integer.to_string()
    |> String.pad_leading(2, "0")
  end
end
