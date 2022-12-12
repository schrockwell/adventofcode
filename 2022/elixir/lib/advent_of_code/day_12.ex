defmodule AdventOfCode.Day12 do
  @behaviour AdventOfCode

  @start_height 0
  @end_height 27

  # This is big enough for the ~4,000 nodes in the input
  @infinity 10_000

  def run(input) do
    # Parse the thing
    {heightmap, start_coord, end_coord} = parse_heightmap(input)

    # Flesh out the heightmap distances using Djikstra's algorithm.
    # Each vertex has distance 1, so the total number of steps is just the distance to the end node
    heightmap_a = traverse(heightmap, start_coord, end_coord)
    answer_a = heightmap_a[end_coord].distance

    # Flesh out the height map BACKWARDS, starting at the END node. The end_coord is nil, so that we are ensured to
    # touch every node. The :downhill? option will invert the logic for determining the cost of traversing the tree,
    # because we are traveling DOWNHILL instead of UPHILL.
    heightmap_b = traverse(heightmap, end_coord, nil, downhill?: true)

    # Find the node at height 'a' with the shortest distance from the end node.
    answer_b =
      heightmap_b
      |> Map.values()
      |> Enum.filter(&(&1.height == height(?a)))
      |> Enum.map(& &1.distance)
      |> Enum.min()

    {answer_a, answer_b}
  end

  ### Parsing

  defp parse_heightmap(input) do
    lines = String.split(input, "\n")

    heightmap =
      for {line, y} <- Enum.with_index(lines),
          {char, x} <- Enum.with_index(String.to_charlist(line)),
          into: %{} do
        {{x, y}, %{height: height(char), distance: @infinity}}
      end

    {start_coord, _} = Enum.find(heightmap, fn {_coord, node} -> node.height == @start_height end)
    {end_coord, _} = Enum.find(heightmap, fn {_coord, node} -> node.height == @end_height end)

    {heightmap, start_coord, end_coord}
  end

  defp height(?S), do: @start_height
  defp height(?E), do: @end_height
  defp height(char), do: char - ?a + 1

  ### Dijkstra
  #
  # Everything in here, I literally just learned today by reading:
  #
  #   https://en.wikipedia.org/wiki/Dijkstra's_algorithm
  #
  defp traverse(heightmap, start_coord, end_coord, opts \\ []) do
    # All node coords begin as unvisited
    unvisited = MapSet.new(Map.keys(heightmap))

    # The initial node has distance 0
    heightmap = Map.update!(heightmap, start_coord, fn node -> %{node | distance: 0} end)

    # Kick off the traversal
    traverse(heightmap, start_coord, end_coord, unvisited, opts)
  end

  # Recursive walking of the heightmap
  defp traverse(heightmap, coord, end_coord, unvisited, opts) do
    node = heightmap[coord]

    next_heightmap =
      coord
      |> unvisited_neighbor_coords(unvisited)
      |> Enum.reduce(heightmap, fn neighbor_coord, heightmap_acc ->
        # Determine the distance from this node to the neighbor
        additional_distance =
          if opts[:downhill?] do
            distance_to_neighbor(neighbor_coord, coord, heightmap_acc)
          else
            distance_to_neighbor(coord, neighbor_coord, heightmap_acc)
          end

        # Calculate the new minimum distance to the neighbor
        neighbor_node = heightmap_acc[neighbor_coord]
        new_distance = min(neighbor_node.distance, node.distance + additional_distance)

        # Put the updated neighbor back into the heightmap
        Map.put(heightmap_acc, neighbor_coord, %{neighbor_node | distance: new_distance})
      end)

    # Mark this node as visited
    next_unvisited = MapSet.delete(unvisited, coord)

    if coord == end_coord or Enum.empty?(next_unvisited) do
      # If we visited the destination, or we visited EVERY NODE, then we're done
      next_heightmap
    else
      # Find the next node, which has the shortest overall distance
      next_coord = Enum.min_by(next_unvisited, fn coord -> next_heightmap[coord].distance end)

      # Recurse
      traverse(next_heightmap, next_coord, end_coord, next_unvisited, opts)
    end
  end

  # Filter out potential neighbor coords based on what has already been visited (and what is within the bounds
  # of the heightmap)
  defp unvisited_neighbor_coords(coord, unvisited) do
    MapSet.intersection(neighbor_coords(coord), unvisited)
  end

  # N, S, E, W
  defp neighbor_coords({x, y}) do
    MapSet.new([{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}])
  end

  # It's valid to travel uphill by 1 level, or downhill by any amount. Otherwise, return @infinity
  # to indicate the terrain is not traversable
  defp distance_to_neighbor(coord, neighbor_coord, heightmap) do
    if heightmap[neighbor_coord].height - heightmap[coord].height > 1, do: @infinity, else: 1
  end
end
