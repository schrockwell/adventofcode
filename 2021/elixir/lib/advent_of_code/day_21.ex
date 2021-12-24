defmodule AdventOfCode.Day21 do
  @behaviour AdventOfCode

  defmodule Player do
    defstruct score: 0, position: 0, wins: 0
  end

  defmodule Game do
    defstruct players: %{
                1 => %Player{},
                2 => %Player{}
              },
              roll: {1, 2, 3},
              player: 1,
              roll_count: 0,
              winning_score: 1000,
              universes: 1
  end

  def run(input) do
    {pos1, pos2} = parse_starting_positions(input)
    p1 = %Player{position: pos1}
    p2 = %Player{position: pos2}
    game = %Game{players: %{1 => p1, 2 => p2}}

    finished_game = play(game)
    losing_player = finished_game.player
    answer_a = finished_game.roll_count * finished_game.players[losing_player].score

    dirac_wins = play_dirac(%{game | winning_score: 21})
    answer_b = max(dirac_wins[1], dirac_wins[2])

    {answer_a, answer_b}
  end

  defp parse_starting_positions([
         "Player 1 starting position: " <> p1,
         "Player 2 starting position: " <> p2
       ]) do
    {String.to_integer(p1) - 1, String.to_integer(p2) - 1}
  end

  # Part 1 win condition
  defp play(
         %{
           players: %{1 => %{score: s1}, 2 => %{score: s2}},
           winning_score: winning_score
         } = game
       )
       when s1 >= winning_score or s2 >= winning_score,
       do: game

  # Part 1 gameplay loop
  defp play(game) do
    moves = Tuple.sum(game.roll)

    next_player =
      game.players[game.player]
      |> advance_player(moves)
      |> add_score()

    %{
      game
      | roll: next_roll(game.roll),
        player: next_player(game.player),
        roll_count: game.roll_count + 3,
        players: Map.put(game.players, game.player, next_player)
    }
    |> play()
  end

  # Move 10 positions (zero-based index, so 0 through 99)
  defp advance_player(player, moves) do
    %{player | position: rem(player.position + moves, 10)}
  end

  # Bump up the player's score based on their position (add 1 to get the actual position value)
  defp add_score(player) do
    %{player | score: player.score + player.position + 1}
  end

  # Part 1 deterministic rolls
  defp next_roll({a, b, c}), do: {rem(a + 2, 100) + 1, rem(b + 2, 100) + 1, rem(c + 2, 100) + 1}

  # Duh
  defp next_player(1), do: 2
  defp next_player(2), do: 1

  # Each player rolls 3 times, so build a LUT of all possible outcomes for three rolls of
  # a three-sided die and how many universes will result
  @dirac_moves for(r1 <- 1..3, r2 <- 1..3, r3 <- 1..3, do: Tuple.sum({r1, r2, r3}))
               |> Enum.group_by(& &1)
               |> Enum.map(fn {roll, sums} -> {roll, length(sums)} end)
               |> Map.new()

  # Part 2 win condition
  defp play_dirac(%{
         players: %{1 => %{score: score}},
         universes: universes,
         winning_score: winning_score
       })
       when score >= winning_score do
    %{1 => universes}
  end

  # Part 2 win condition
  defp play_dirac(%{
         players: %{2 => %{score: score}},
         universes: universes,
         winning_score: winning_score
       })
       when score >= winning_score do
    %{2 => universes}
  end

  # Part 2 main gameplay loop; returns a map of %{player_id => win_count}
  defp play_dirac(game) do
    @dirac_moves
    |> Enum.map(fn {moves, universes} ->
      next_player =
        game.players[game.player]
        |> advance_player(moves)
        |> add_score()

      next_game = %{
        game
        | player: next_player(game.player),
          players: Map.put(game.players, game.player, next_player),

          # This is the key operation; the number of universes MULTIPLIES for all possibilities
          # on this player's current turn
          universes: game.universes * universes
      }

      play_dirac(next_game)
    end)
    |> Enum.reduce(%{1 => 0, 2 => 0}, fn new_wins, wins ->
      # Sum up all wins for each player
      Map.merge(wins, new_wins, fn _, v1, v2 -> v1 + v2 end)
    end)
  end
end
