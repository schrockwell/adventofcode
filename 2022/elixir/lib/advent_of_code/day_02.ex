defmodule AdventOfCode.Day02 do
  @behaviour AdventOfCode

  def run(input) do
    answer_a =
      input
      |> Enum.map(&(&1 |> parse_game_a() |> score_game()))
      |> Enum.sum()

    answer_b =
      input
      |> Enum.map(&(&1 |> parse_game_b() |> score_game()))
      |> Enum.sum()

    {answer_a, answer_b}
  end

  ### Parsing

  defp parse_game_a(<<opp::binary-1, " ", me::binary-1>>) do
    %{opp: parse_move(opp), me: parse_move(me)}
  end

  defp parse_game_b(<<opp::binary-1, " ", outcome::binary-1>>) do
    %{opp: parse_move(opp), outcome: parse_outcome(outcome)}
  end

  defp parse_move(move) when move in ["A", "X"], do: :rock
  defp parse_move(move) when move in ["B", "Y"], do: :paper
  defp parse_move(move) when move in ["C", "Z"], do: :scissors

  defp parse_outcome("X"), do: :loss
  defp parse_outcome("Y"), do: :draw
  defp parse_outcome("Z"), do: :win

  ### Game logic

  defp outcome(same = _op, same = _me), do: :draw
  defp outcome(:rock, :scissors), do: :loss
  defp outcome(:scissors, :paper), do: :loss
  defp outcome(:paper, :rock), do: :loss
  defp outcome(_, _), do: :win

  defp determine_me(:draw, opp), do: opp
  defp determine_me(:win, :rock), do: :paper
  defp determine_me(:win, :paper), do: :scissors
  defp determine_me(:win, :scissors), do: :rock
  defp determine_me(:loss, :rock), do: :scissors
  defp determine_me(:loss, :paper), do: :rock
  defp determine_me(:loss, :scissors), do: :paper

  ### Scoring

  defp score_game(%{opp: opp, me: me}) do
    outcome = outcome(opp, me)
    score_me(me) + score_outcome(outcome)
  end

  defp score_game(%{opp: opp, outcome: outcome}) do
    me = determine_me(outcome, opp)
    score_me(me) + score_outcome(outcome)
  end

  defp score_me(:rock), do: 1
  defp score_me(:paper), do: 2
  defp score_me(:scissors), do: 3

  defp score_outcome(:loss), do: 0
  defp score_outcome(:draw), do: 3
  defp score_outcome(:win), do: 6
end
