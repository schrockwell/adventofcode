defmodule AdventOfCode.Day21 do
  @behaviour AdventOfCode

  defmodule Game do
    defstruct scores: {0, 0}, positions: {0, 0}, roll: {1, 2, 3}, player: 0, roll_count: 0
  end

  def run(input) do
    pos = parse_starting_positions(input)
    game = %Game{positions: pos}

    finished_game = play(game)

    losing_player = finished_game.player
    answer_a = finished_game.roll_count * elem(finished_game.scores, losing_player)

    {answer_a, "todo"}
  end

  defp parse_starting_positions([
         "Player 1 starting position: " <> p1,
         "Player 2 starting position: " <> p2
       ]) do
    {String.to_integer(p1) - 1, String.to_integer(p2) - 1}
  end

  defp play(%{scores: {s1, s2}} = game) when s1 >= 1000 or s2 >= 1000, do: game

  defp play(game) do
    moves = Tuple.sum(game.roll)

    position = elem(game.positions, game.player)
    position = rem(position + moves, 10)
    next_positions = put_elem(game.positions, game.player, position)

    score = elem(game.scores, game.player)
    score = score + position + 1
    next_scores = put_elem(game.scores, game.player, score)

    %Game{
      scores: next_scores,
      positions: next_positions,
      roll: next_roll(game.roll),
      player: next_player(game.player),
      roll_count: game.roll_count + 3
    }
    |> play()
  end

  defp next_roll({a, b, c}), do: {rem(a + 2, 100) + 1, rem(b + 2, 100) + 1, rem(c + 2, 100) + 1}

  defp next_player(0), do: 1
  defp next_player(1), do: 0
end
