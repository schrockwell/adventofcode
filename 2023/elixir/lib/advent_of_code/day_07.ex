defmodule AdventOfCode.Day07 do
  @behaviour AdventOfCode

  # Weaker cards are... stronger?
  @part_1_cards %{
    "A" => 13,
    "K" => 12,
    "Q" => 11,
    "J" => 10,
    "T" => 9,
    "9" => 8,
    "8" => 7,
    "7" => 6,
    "6" => 5,
    "5" => 4,
    "4" => 3,
    "3" => 2,
    "2" => 1
  }

  # In part 2, jokers are weakest
  @part_2_cards %{
    "A" => 13,
    "K" => 12,
    "Q" => 11,
    "T" => 10,
    "9" => 9,
    "8" => 8,
    "7" => 7,
    "6" => 6,
    "5" => 5,
    "4" => 4,
    "3" => 3,
    "2" => 2,
    "J" => 1
  }

  @joker @part_2_cards["J"]

  # Part 1
  def run(_basename, 1, input) do
    input
    |> parse_hands(@part_1_cards)
    |> score_hands()
  end

  # Part 2
  def run(_basename, 2, input) do
    input
    |> parse_hands(@part_2_cards)
    |> Enum.map(&remove_jokers/1)
    |> score_hands()
  end

  defp score_hands(hands) do
    hands
    |> Enum.sort_by(fn %{hand: hand, non_jokers: non_jokers} ->
      # Order by hand strength first, then by cards second
      hand_strength =
        non_jokers
        |> Enum.sort()
        |> sorted_hand_strength()

      {hand_strength, hand}
    end)
    |> Enum.with_index()
    |> Enum.map(fn {hand, index} ->
      hand.bid * (index + 1)
    end)
    |> Enum.sum()
  end

  # Abuse pattern matching to determine the score for any non-jokers remaining in the hand
  defp sorted_hand_strength(hand_without_jokers)
  # Five of a kind
  defp sorted_hand_strength([a, a, a, a, a]), do: 7
  defp sorted_hand_strength([a, a, a, a]), do: 7
  defp sorted_hand_strength([a, a, a]), do: 7
  defp sorted_hand_strength([a, a]), do: 7
  defp sorted_hand_strength([_]), do: 7
  defp sorted_hand_strength([]), do: 7
  # Four of a kind
  defp sorted_hand_strength([a, a, a, a, _]), do: 6
  defp sorted_hand_strength([_, a, a, a, a]), do: 6
  defp sorted_hand_strength([_, a, a, a]), do: 6
  defp sorted_hand_strength([a, a, a, _]), do: 6
  defp sorted_hand_strength([_, a, a]), do: 6
  defp sorted_hand_strength([a, a, _]), do: 6
  defp sorted_hand_strength([_, _]), do: 6
  # Full house
  defp sorted_hand_strength([a, a, a, b, b]), do: 5
  defp sorted_hand_strength([a, a, b, b, b]), do: 5
  defp sorted_hand_strength([a, a, b, b]), do: 5
  defp sorted_hand_strength([_, a, a, a]), do: 5
  defp sorted_hand_strength([a, a, a, _]), do: 5
  # Three of a kind
  defp sorted_hand_strength([a, a, a, _, _]), do: 4
  defp sorted_hand_strength([_, a, a, a, _]), do: 4
  defp sorted_hand_strength([_, _, a, a, a]), do: 4
  defp sorted_hand_strength([a, a, _, _]), do: 4
  defp sorted_hand_strength([_, a, a, _]), do: 4
  defp sorted_hand_strength([_, _, a, a]), do: 4
  defp sorted_hand_strength([_, _, _]), do: 4
  # Two pair
  defp sorted_hand_strength([a, a, b, b, _]), do: 3
  defp sorted_hand_strength([a, a, _, b, b]), do: 3
  defp sorted_hand_strength([_, a, a, b, b]), do: 3
  # One pair
  defp sorted_hand_strength([a, a, _, _, _]), do: 2
  defp sorted_hand_strength([_, a, a, _, _]), do: 2
  defp sorted_hand_strength([_, _, a, a, _]), do: 2
  defp sorted_hand_strength([_, _, _, a, a]), do: 2
  defp sorted_hand_strength([_, _, _, _]), do: 2
  # High card
  defp sorted_hand_strength([_, _, _, _, _]), do: 1

  # Part 2 - remove jokers from the hand list
  defp remove_jokers(game) do
    Map.update!(game, :non_jokers, fn hand ->
      Enum.filter(hand, fn card -> card != @joker end)
    end)
  end

  # Parsing
  defp parse_hands(input, strengths) do
    input
    |> Enum.map(fn line ->
      [hand_str, bid] = String.split(line, " ")
      hand = hand_str |> String.codepoints() |> Enum.map(&strengths[&1])
      bid = String.to_integer(bid)
      %{hand: hand, non_jokers: hand, bid: bid, input: hand_str}
    end)
  end
end
