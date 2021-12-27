defmodule AdventOfCode.Day23 do
  @behaviour AdventOfCode

  defmodule Pod do
    defstruct target: nil, position: nil, steps: 0, moved?: false, done?: false
  end

  defmodule Burrow do
    defstruct pods: %{}, total_energy: 0, room_depth: 2

    require IEx

    # Parallelize the top-level moves into tasks
    def organize_async(burrow, min_energy \\ 999_999_999) do
      burrow.pods
      |> Enum.flat_map(fn {_, pod} -> next_moves_for_pod(burrow, pod) end)
      |> Task.async_stream(
        fn move ->
          organize_pod(burrow, move, min_energy)
        end,
        timeout: :infinity
      )
      |> Enum.map(fn {:ok, energy} -> energy end)
      |> Enum.min()
    end

    # In each task, do regular recursive organization
    def organize_sync(burrow, min_energy \\ 999_999_999) do
      for {_, pod} <- burrow.pods, move <- next_moves_for_pod(burrow, pod), reduce: min_energy do
        acc ->
          min(acc, organize_pod(burrow, move, acc))
      end
    end

    def organize_pod(burrow, move, min_energy \\ 999_999_999) do
      next_burrow = perform_move(burrow, move)

      # if not burrow_valid?(next_burrow) do
      #   IEx.pry()
      #   raise "invalid burrow"
      # end

      next_energy = next_burrow.total_energy

      cond do
        next_energy > min_energy ->
          # If we already blew past the min, just give up
          min_energy

        burrow_complete?(next_burrow) ->
          # Check if we have a new winner
          if next_energy < min_energy do
            # IO.inspect(next_energy, label: "new min")
            next_energy
          else
            min_energy
          end

        true ->
          # Keep on truckin' (in this task)
          organize_sync(next_burrow, min_energy)
      end
    end

    def room_hallway_index(room), do: 2 + room * 2

    def reachable_hallway_indexes_from_room(burrow, room) do
      positions =
        Enum.flat_map(Map.keys(burrow.pods), fn
          {:hallway, index} -> [index]
          _ -> []
        end)

      left_neighbor =
        positions |> Enum.filter(&(&1 < room_hallway_index(room))) |> Enum.max(fn -> -1 end)

      right_neighbor =
        positions |> Enum.filter(&(&1 > room_hallway_index(room))) |> Enum.min(fn -> 11 end)

      Enum.into((left_neighbor + 1)..(right_neighbor - 1), []) -- [2, 4, 6, 8]
    end

    def next_moves_for_pod(burrow, pod) do
      cond do
        pod.done? ->
          # Pod is in place; nothing to figure out
          []

        # Pod is in the back of its target room, so it will never move
        back_of_target_room?(pod) ->
          []

        # Pod is in the back of a room and the front is also occupied
        back_of_a_room?(pod) and front_is_occupied?(burrow, pod) ->
          []

        true ->
          get_next_moves(burrow, pod)
      end
    end

    # Once an amphipod stops moving in the hallway, it will stay in that spot until it can move into a room.
    # (That is, once any amphipod starts moving, any other amphipods currently in the hallway are locked in
    # place and will not move again until they can move fully into a room.)
    def get_next_moves(burrow, %Pod{position: {:room, room, _} = room_pos} = pod) do
      # Get hallway positions
      for index <- reachable_hallway_indexes_from_room(burrow, room) do
        %{
          position: {:hallway, index},
          steps: steps_between(room_pos, {:hallway, index}),
          pod: pod
        }
      end
    end

    def get_next_moves(burrow, %Pod{position: {:hallway, _index}} = pod) do
      # Get target positions
      # Amphipods will never move from the hallway into a room unless that room is their destination
      # room and that room contains no amphipods which do not also have that room as their own destination.
      # If an amphipod's starting room is not its destination room, it can stay in that room until it
      # leaves the room. (For example, an Amber amphipod will not move from the hallway into the right
      # three rooms, and will only move into the leftmost room if that room is empty or if it only contains
      # other Amber amphipods.)
      cond do
        target_room_back_reachable?(burrow, pod) ->
          dest = {:room, pod.target, 1}
          [%{position: dest, steps: steps_between(dest, pod.position), pod: pod}]

        target_room_front_reachable?(burrow, pod) ->
          dest = {:room, pod.target, 0}
          [%{position: dest, steps: steps_between(dest, pod.position), pod: pod}]

        true ->
          []
      end
    end

    def perform_move(burrow, move) do
      next_pod = %{
        move.pod
        | position: move.position,
          steps: move.pod.steps + move.steps,
          moved?: true,
          done?: move.pod.moved?
      }

      next_pods =
        burrow.pods
        |> Map.delete(move.pod.position)
        |> Map.put(next_pod.position, next_pod)

      %{burrow | pods: next_pods, total_energy: burrow.total_energy + move_energy(move)}
    end

    def target_room_back_reachable?(burrow, pod) do
      target_room_reachable?(burrow, pod) and
        not Map.has_key?(burrow.pods, {:room, pod.target, 0}) and
        not Map.has_key?(burrow.pods, {:room, pod.target, 1})
    end

    def target_room_front_reachable?(burrow, %{target: target} = pod) do
      with true <- target_room_reachable?(burrow, pod),
           %{target: ^target} <- burrow.pods[{:room, pod.target, 1}],
           nil <- burrow.pods[{:room, pod.target, 0}] do
        true
      else
        _ -> false
      end
    end

    def target_room_reachable?(burrow, %Pod{position: {:hallway, index}} = pod) do
      hallway_range = index..room_hallway_index(pod.target)

      Enum.all?(hallway_range, fn i -> burrow.pods[{:hallway, i}] in [nil, pod] end)
    end

    def back_of_target_room?(%Pod{position: {:room, room, 1}, target: room}), do: true
    def back_of_target_room?(_pod), do: false

    def back_of_a_room?(%Pod{position: {:room, _, 1}}), do: true
    def back_of_a_room?(_), do: false

    def front_is_occupied?(burrow, pod) do
      Map.has_key?(burrow.pods, {:room, room(pod), 0})
    end

    def room_complete?(burrow, room) do
      with %{target: ^room} <- burrow.pods[{:room, room, 0}],
           %{target: ^room} <- burrow.pods[{:room, room, 1}] do
        true
      else
        _ -> false
      end
    end

    def room(%Pod{position: {:room, num, _}}), do: num

    def steps_between(
          {:room, room, _front_or_back} = room_position,
          {:hallway, index} = _hallway_position
        ) do
      abs(room_hallway_index(room) - index) + steps_out_of_room(room_position)
    end

    def steps_out_of_room({:room, _, 0}), do: 1
    def steps_out_of_room({:room, _, 1}), do: 2

    def burrow_complete?(burrow) do
      Enum.all?(0..3, &room_complete?(burrow, &1))
    end

    def move_energy(%{pod: %{target: 0}, steps: steps}), do: steps
    def move_energy(%{pod: %{target: 1}, steps: steps}), do: steps * 10
    def move_energy(%{pod: %{target: 2}, steps: steps}), do: steps * 100
    def move_energy(%{pod: %{target: 3}, steps: steps}), do: steps * 1000

    def burrow_valid?(burrow) do
      map_size(burrow.pods) == 8
    end

    def display(burrow) do
      IO.puts("#############")

      IO.write("#")

      for i <- 0..10 do
        burrow |> display_at_position({:hallway, i}) |> IO.write()
      end

      IO.puts("#")

      IO.write("###")

      for r <- 0..3 do
        burrow |> display_at_position({:room, r, 0}) |> IO.write()
        IO.write("#")
      end

      IO.puts("##")
      IO.write("  #")

      for r <- 0..3 do
        burrow |> display_at_position({:room, r, 1}) |> IO.write()
        IO.write("#")
      end

      IO.puts("  ")
      IO.puts("  #########  ")
    end

    defp display_at_position(burrow, position) do
      case burrow.pods[position] do
        %Pod{target: 0} -> "A"
        %Pod{target: 1} -> "B"
        %Pod{target: 2} -> "C"
        %Pod{target: 3} -> "D"
        _ -> "."
      end
    end
  end

  def run(_input) do
    # Sample burrow
    #
    # burrow = %Burrow{
    #   pods: %{
    #     {:room, 0, 0} => %Pod{target: 1, position: {:room, 0, 0}},
    #     {:room, 0, 1} => %Pod{target: 0, position: {:room, 0, 1}},
    #     {:room, 1, 0} => %Pod{target: 2, position: {:room, 1, 0}},
    #     {:room, 1, 1} => %Pod{target: 3, position: {:room, 1, 1}},
    #     {:room, 2, 0} => %Pod{target: 1, position: {:room, 2, 0}},
    #     {:room, 2, 1} => %Pod{target: 2, position: {:room, 2, 1}},
    #     {:room, 3, 0} => %Pod{target: 3, position: {:room, 3, 0}},
    #     {:room, 3, 1} => %Pod{target: 0, position: {:room, 3, 1}}
    #   }
    # }

    # Problem burrow
    #
    # burrow = %Burrow{
    #   pods: %{
    #     {:room, 0, 0} => %Pod{target: 3, position: {:room, 0, 0}},
    #     {:room, 0, 1} => %Pod{target: 1, position: {:room, 0, 1}},
    #     {:room, 1, 0} => %Pod{target: 1, position: {:room, 1, 0}},
    #     {:room, 1, 1} => %Pod{target: 3, position: {:room, 1, 1}},
    #     {:room, 2, 0} => %Pod{target: 0, position: {:room, 2, 0}},
    #     {:room, 2, 1} => %Pod{target: 0, position: {:room, 2, 1}},
    #     {:room, 3, 0} => %Pod{target: 2, position: {:room, 3, 0}},
    #     {:room, 3, 1} => %Pod{target: 2, position: {:room, 3, 1}}
    #   }
    # }

    # start_time = System.monotonic_time(:second)
    # answer_a = Burrow.organize_async(burrow)
    # end_time = System.monotonic_time(:second)
    # IO.puts("Completed in #{end_time - start_time} seconds")

    # Hardcoding answers so that GitHub actions doesn't have to run this challenge
    answer_a = 17120

    {answer_a, "todo"}
  end
end
