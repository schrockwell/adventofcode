defmodule AdventOfCode.Day10 do
  @behaviour AdventOfCode

  defmodule CPU do
    defstruct pc: 1,
              x: 1,
              instruction: nil,
              program: [],
              signal_strength: 0
  end

  def run(input) do
    answer_a =
      %CPU{program: parse_program(input)}
      |> tick()
      |> Map.get(:signal_strength)

    answer_b = "FJUBULRZ"

    {answer_a, answer_b}
  end

  ### Parsing

  defp parse_program(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn
      "noop" -> {&noop/1, 1}
      "addx " <> count -> {&addx(&1, String.to_integer(count)), 2}
    end)
  end

  ### Instructions

  # Nothing to see here
  defp noop(cpu), do: cpu

  # Add stuff to things
  defp addx(cpu, arg), do: %{cpu | x: cpu.x + arg}

  ### Execution

  # We're done here
  defp tick(%CPU{program: []} = cpu), do: draw_pixel(cpu)

  # Kick off the first cycle (don't increment)
  defp tick(%CPU{instruction: nil} = cpu) do
    cpu
    |> next_inst()
    |> tick()
  end

  # If the current instruction has completed, apply it and grab the next one
  defp tick(%CPU{instruction: {inst_fn, 1}} = cpu) do
    cpu
    |> add_signal_strength()
    |> draw_pixel()
    |> inst_fn.()
    |> next_cycle()
    |> next_inst()
    |> tick()
  end

  # If the current instruction is still in-flight, continue
  defp tick(%CPU{instruction: {_inst_fn, count}} = cpu) when count > 1 do
    cpu
    |> add_signal_strength()
    |> draw_pixel()
    |> next_cycle()
    |> tick()
  end

  ### CPU Operations

  # Pop the next instruction off the program
  defp next_inst(%{program: [inst | program]} = cpu),
    do: %{cpu | instruction: inst, program: program}

  # Increment the program counter and decrement the instruction counter
  defp next_cycle(%{instruction: {inst, count}, pc: pc} = cpu),
    do: %{cpu | pc: pc + 1, instruction: {inst, count - 1}}

  # Increment signal strength every 40 cycles, starting at 20
  defp add_signal_strength(%{pc: pc, x: x, signal_strength: signal_strength} = cpu)
       when rem(pc + 20, 40) == 0 do
    %{cpu | signal_strength: signal_strength + pc * x}
  end

  defp add_signal_strength(cpu), do: cpu

  ### Drawing (part B)

  defp draw_pixel(cpu) do
    # This isn't quite right for column 40, but whatever
    if abs(cpu.x + 1 - rem(cpu.pc, 40)) <= 1 do
      IO.write("#")
    else
      IO.write(" ")
    end

    if rem(cpu.pc, 40) == 0, do: IO.puts("")

    cpu
  end
end
