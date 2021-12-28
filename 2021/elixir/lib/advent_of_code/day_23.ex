defmodule AdventOfCode.Day23 do
  @behaviour AdventOfCode
  @a 0
  @b 1
  @c 2
  @d 3

  defmodule Pod do
    defstruct target: nil, position: nil, steps: 0, moved_to_hallway?: false, done?: false
  end

  defmodule Burrow do
    @a 0
    @b 1
    @c 2
    @d 3

    defstruct pods: %{}, total_energy: 0, room_depth: nil

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

      if not burrow_valid?(next_burrow) do
        IEx.pry()
        raise "invalid burrow"
      end

      next_energy = next_burrow.total_energy

      cond do
        next_energy > min_energy ->
          # If we already blew past the min, just give up
          min_energy

        burrow_complete?(next_burrow) ->
          # Check if we have a new winner
          if next_energy < min_energy do
            IO.inspect(next_energy, label: "new min")
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
      if pod.done? do
        # Pod is in place; no moves to consider
        []
      else
        get_next_moves(burrow, pod)
      end
    end

    # Once an amphipod stops moving in the hallway, it will stay in that spot until it can move into a room.
    # (That is, once any amphipod starts moving, any other amphipods currently in the hallway are locked in
    # place and will not move again until they can move fully into a room.)
    def get_next_moves(burrow, %Pod{position: {:room, room, _} = room_pos} = pod) do
      # Pod is blocked by other pods in the room's doorway
      if room_occupied_ahead?(burrow, pod) do
        []
      else
        # Get hallway positions
        for index <- reachable_hallway_indexes_from_room(burrow, room) do
          %{
            position: {:hallway, index},
            steps: steps_between(room_pos, {:hallway, index}),
            pod: pod
          }
        end
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
      can_walk? = hallway_clear_to_room_doorway?(burrow, pod)
      target_position = position_in_target_room(burrow, pod)

      if can_walk? && target_position do
        [
          %{
            position: target_position,
            steps: steps_between(target_position, pod.position),
            pod: pod
          }
        ]
      else
        []
      end
    end

    def position_in_target_room(burrow, %Pod{target: target}) do
      0..(burrow.room_depth - 1)
      |> Enum.map(fn i -> burrow.pods[{:room, target, i}] end)
      |> case do
        [nil, nil] ->
          {:room, target, 1}

        [nil, %Pod{target: ^target}] ->
          {:room, target, 0}

        [nil, nil, nil, nil] ->
          {:room, target, 3}

        [nil, nil, nil, %Pod{target: ^target}] ->
          {:room, target, 2}

        [nil, nil, %Pod{target: ^target}, %Pod{target: ^target}] ->
          {:room, target, 1}

        [nil, %Pod{target: ^target}, %Pod{target: ^target}, %Pod{target: ^target}] ->
          {:room, target, 0}

        _ ->
          nil
      end
    end

    def perform_move(burrow, move) do
      next_pod = %{
        move.pod
        | position: move.position,
          steps: move.pod.steps + move.steps,
          moved_to_hallway?: true,
          done?: move.pod.moved_to_hallway?
      }

      next_pods =
        burrow.pods
        |> Map.delete(move.pod.position)
        |> Map.put(next_pod.position, next_pod)

      %{burrow | pods: next_pods, total_energy: burrow.total_energy + move_energy(move)}
    end

    def hallway_clear_to_room_doorway?(burrow, %Pod{position: {:hallway, index}} = pod) do
      hallway_range = index..room_hallway_index(pod.target)

      Enum.all?(hallway_range, fn i -> burrow.pods[{:hallway, i}] in [nil, pod] end)
    end

    def room_occupied_ahead?(_burrow, %Pod{position: {:hallway, _}}), do: false
    def room_occupied_ahead?(_burrow, %Pod{position: {:room, _room, 0}}), do: false

    def room_occupied_ahead?(burrow, %Pod{position: {:room, room, index}}) do
      Enum.any?((index - 1)..0, fn i ->
        Map.has_key?(burrow.pods, {:room, room, i})
      end)
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
          {:room, room, room_index},
          {:hallway, hallway_index}
        ) do
      abs(room_hallway_index(room) - hallway_index) + room_index + 1
    end

    def burrow_complete?(burrow) do
      Enum.all?(0..3, &room_complete?(burrow, &1))
    end

    def move_energy(%{pod: %{target: @a}, steps: steps}), do: steps
    def move_energy(%{pod: %{target: @b}, steps: steps}), do: steps * 10
    def move_energy(%{pod: %{target: @c}, steps: steps}), do: steps * 100
    def move_energy(%{pod: %{target: @d}, steps: steps}), do: steps * 1000

    def burrow_valid?(burrow) do
      map_size(burrow.pods) == 4 * burrow.room_depth
    end

    def display(burrow) do
      IO.puts("#############")

      IO.write("#")

      for i <- 0..10 do
        burrow |> display_at_position({:hallway, i}) |> IO.write()
      end

      IO.puts("#")

      for i <- 0..(burrow.room_depth - 1) do
        if i == 0, do: IO.write("###"), else: IO.write("  #")

        for r <- 0..3 do
          burrow |> display_at_position({:room, r, i}) |> IO.write()
          IO.write("#")
        end

        if i == 0, do: IO.puts("##"), else: IO.puts("  ")
      end

      IO.puts("  #########  ")
    end

    defp display_at_position(burrow, position) do
      case burrow.pods[position] do
        %Pod{target: @a} -> "A"
        %Pod{target: @b} -> "B"
        %Pod{target: @c} -> "C"
        %Pod{target: @d} -> "D"
        _ -> "."
      end
    end
  end

  def run(_input) do
    # Sample burrow
    #
    # burrow = %Burrow{
    #   room_depth: 2,
    #   pods: %{
    #     {:room, 0, 0} => %Pod{target: @b, position: {:room, 0, 0}},
    #     {:room, 0, 1} => %Pod{target: @a, position: {:room, 0, 1}, done?: true},
    #     {:room, 1, 0} => %Pod{target: @c, position: {:room, 1, 0}},
    #     {:room, 1, 1} => %Pod{target: @d, position: {:room, 1, 1}},
    #     {:room, 2, 0} => %Pod{target: @b, position: {:room, 2, 0}},
    #     {:room, 2, 1} => %Pod{target: @c, position: {:room, 2, 1}, done?: true},
    #     {:room, 3, 0} => %Pod{target: @d, position: {:room, 3, 0}},
    #     {:room, 3, 1} => %Pod{target: @a, position: {:room, 3, 1}}
    #   }
    # }

    # Part 1 burrow
    #
    _burrow_a = %Burrow{
      room_depth: 2,
      pods: %{
        {:room, 0, 0} => %Pod{target: @d, position: {:room, 0, 0}},
        {:room, 0, 1} => %Pod{target: @b, position: {:room, 0, 1}},
        {:room, 1, 0} => %Pod{target: @b, position: {:room, 1, 0}},
        {:room, 1, 1} => %Pod{target: @d, position: {:room, 1, 1}},
        {:room, 2, 0} => %Pod{target: @a, position: {:room, 2, 0}},
        {:room, 2, 1} => %Pod{target: @a, position: {:room, 2, 1}},
        {:room, 3, 0} => %Pod{target: @c, position: {:room, 3, 0}},
        {:room, 3, 1} => %Pod{target: @c, position: {:room, 3, 1}}
      }
    }

    # Part 2 burrow
    burrow_b = %Burrow{
      room_depth: 4,
      pods: %{
        # Room 0
        {:room, 0, 0} => %Pod{target: @d, position: {:room, 0, 0}},
        {:room, 0, 1} => %Pod{target: @d, position: {:room, 0, 1}},
        {:room, 0, 2} => %Pod{target: @d, position: {:room, 0, 2}},
        {:room, 0, 3} => %Pod{target: @b, position: {:room, 0, 3}},
        # Room 1
        {:room, 1, 0} => %Pod{target: @b, position: {:room, 1, 0}},
        {:room, 1, 1} => %Pod{target: @c, position: {:room, 1, 1}},
        {:room, 1, 2} => %Pod{target: @b, position: {:room, 1, 2}},
        {:room, 1, 3} => %Pod{target: @d, position: {:room, 1, 3}},
        # Room 2
        {:room, 2, 0} => %Pod{target: @a, position: {:room, 2, 0}},
        {:room, 2, 1} => %Pod{target: @b, position: {:room, 2, 1}},
        {:room, 2, 2} => %Pod{target: @a, position: {:room, 2, 2}},
        {:room, 2, 3} => %Pod{target: @a, position: {:room, 2, 3}},
        # Room 3
        {:room, 3, 0} => %Pod{target: @c, position: {:room, 3, 0}},
        {:room, 3, 1} => %Pod{target: @a, position: {:room, 3, 1}},
        {:room, 3, 2} => %Pod{target: @c, position: {:room, 3, 2}},
        {:room, 3, 3} => %Pod{target: @c, position: {:room, 3, 3}}
      }
    }

    # Hardcoding this answer since it takes several minutes to run
    answer_a = 17120
    # answer_a = Burrow.organize_async(burrow_a)

    start_time = System.monotonic_time(:second)
    answer_b = Burrow.organize_async(burrow_b)
    end_time = System.monotonic_time(:second)
    IO.puts("Completed in #{end_time - start_time} seconds")

    {answer_a, answer_b}
  end
end
