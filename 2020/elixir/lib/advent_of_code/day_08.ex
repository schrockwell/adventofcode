defmodule AdventOfCode.Day08 do
  @behaviour AdventOfCode

  def run(input) do
    state = %{
      # Accumulator
      acc: 0,
      # Program counter
      pc: 0,
      # List of parsed instruction
      program: parse_instructions(input),
      # Bookkeeping to detect infinite loops
      touched: MapSet.new()
    }

    %{acc: answer_a} = run_program(state)

    %{acc: answer_b} = mutate_jmp_or_nop(state)

    {answer_a, answer_b}
  end

  defp parse_instructions(input) do
    Enum.map(input, fn line ->
      [instruction, offset] = String.split(line, " ")

      {String.to_atom(instruction), String.to_integer(offset)}
    end)
  end

  defp run_program(state) do
    cond do
      MapSet.member?(state.touched, state.pc) ->
        # Infinite loop detected
        state

      state.pc >= length(state.program) ->
        # Ran out of instructions
        state

      true ->
        # Remember that this instruction was evaluated
        state = %{state | touched: MapSet.put(state.touched, state.pc)}

        state =
          case Enum.at(state.program, state.pc) do
            {:jmp, offset} ->
              %{state | pc: state.pc + offset}

            {:acc, delta} ->
              %{state | pc: state.pc + 1, acc: state.acc + delta}

            {:nop, _} ->
              %{state | pc: state.pc + 1}
          end

        run_program(state)
    end
  end

  defp mutate_jmp_or_nop(state) do
    state.program
    |> Enum.with_index()
    |> Enum.find_value(fn
      {{:jmp, offset}, index} ->
        new_program = List.replace_at(state.program, index, {:nop, index})
        new_state = run_program(%{state | program: new_program})
        if normal_exit?(new_state), do: new_state

      {{:nop, offset}, index} ->
        new_program = List.replace_at(state.program, index, {:jmp, index})
        new_state = run_program(%{state | program: new_program})
        if normal_exit?(new_state), do: new_state

      _ ->
        nil
    end)
  end

  defp normal_exit?(state), do: state.pc == length(state.program)
end
