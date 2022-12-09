defmodule AdventOfCode do
  @callback run(input :: String.t()) :: {:skip | term, :skip | term}

  def run(day, basename \\ :input) do
    with {:ok, _expected_a, _expected_b, input} <- read_input_file(day, basename) do
      {answer_a, answer_b} = day_module(day).run(input)

      {:ok, answer_a, answer_b}
    end
  end

  def run!(day, basename \\ :input) do
    with {:ok, expected_a, expected_b, input} <- read_input_file(day, basename) do
      {answer_a, answer_b} = day_module(day).run(input)

      if answer_a != :skip and to_string(answer_a) != expected_a do
        raise "Wrong answer for A; expected #{expected_a}, got #{answer_a}"
      end

      if answer_b != :skip and to_string(answer_b) != expected_b do
        raise "Wrong answer for B; expected #{expected_b}, got #{answer_b}"
      end

      {:ok, answer_a, answer_b}
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

  defp read_input_file(day, basename) do
    ["priv", "days", format_day(day), "#{basename}.txt"]
    |> Path.join()
    |> File.read()
    |> case do
      {:ok, contents} ->
        [answer_a, answer_b, "---" | input] = String.split(contents, "\n")
        {:ok, answer_a, answer_b, Enum.join(input, "\n")}

      error ->
        error
    end
  end

  defp format_day(day) do
    day
    |> Integer.to_string()
    |> String.pad_leading(2, "0")
  end
end
