defmodule AdventOfCode.Day18 do
  @behaviour AdventOfCode

  # Eh, close enough
  @infinity 100_000

  def run(input) do
    rock_coords = parse_rock_coords(input)

    answer_a =
      rock_coords
      |> Enum.map(&count_exposed_faces(&1, rock_coords))
      |> Enum.sum()

    answer_b =
      rock_coords
      |> count_outside_rock_edges()

    {answer_a, answer_b}
  end

  ### Parsing

  defp parse_rock_coords(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
    |> MapSet.new()
  end

  ### Part A

  # Solves part A
  defp count_exposed_faces(rock_coord, rock_coords) do
    rock_coord
    |> neighbor_coords()
    |> Enum.count(fn c -> not Enum.member?(rock_coords, c) end)
  end

  # Returns a MapSet of six neighboring coords that touch the faces of this coord
  defp neighbor_coords({x, y, z}) do
    MapSet.new([
      {x - 1, y, z},
      {x + 1, y, z},
      {x, y - 1, z},
      {x, y + 1, z},
      {x, y, z - 1},
      {x, y, z + 1}
    ])
  end

  ### Part B

  defp count_outside_rock_edges(rock_coords) do
    # Determine the problem space
    {x_range, y_range, z_range} = problem_bounds(rock_coords)

    # Build up the map of nodes by 3D coords
    scan =
      for x <- x_range, y <- y_range, z <- z_range, into: %{} do
        coord = {x, y, z}
        {coord, %{distance: @infinity, rock?: MapSet.member?(rock_coords, coord)}}
      end

    # Start… somewhere in the corner
    start_coord = {x_range.first, y_range.first, z_range.first}

    # Run Djikstra to calculate the distances to every outside air node
    scan = traverse(scan, start_coord)

    # Only outside air will have distance 0
    outside_air_coords =
      scan
      |> Enum.filter(fn {_, n} -> n.distance == 0 end)
      |> Enum.map(fn {c, _} -> c end)

    # To generate the final total, count rock faces who are also touching outside air nodes
    rock_coords
    |> Enum.map(&count_shared_faces(&1, outside_air_coords))
    |> Enum.sum()
  end

  # Returns a threeple of coord ranges over which we will perform Djikstra
  defp problem_bounds(cubes) do
    {min_x, max_x} = cubes |> Enum.map(&elem(&1, 0)) |> Enum.min_max()
    {min_y, max_y} = cubes |> Enum.map(&elem(&1, 1)) |> Enum.min_max()
    {min_z, max_z} = cubes |> Enum.map(&elem(&1, 2)) |> Enum.min_max()

    # Add 1 cube of padding around the lava, so that steam can expand around it
    {(min_x - 1)..(max_x + 1), (min_y - 1)..(max_y + 1), (min_z - 1)..(max_z + 1)}
  end

  # Djikstra initialization
  defp traverse(scan, start_coord) do
    # All node coords begin as unvisited
    unvisited = MapSet.new(Map.keys(scan))

    # The initial air node has distance 0
    scan = Map.update!(scan, start_coord, fn node -> %{node | distance: 0} end)

    # Kick off the traversal
    traverse(scan, start_coord, unvisited)
  end

  # Djikstra, my boiiiii
  defp traverse(scan, coord, unvisited) do
    node = scan[coord]

    next_scan =
      coord
      |> unvisited_neighbor_coords(unvisited)
      |> Enum.reduce(scan, fn neighbor_coord, scan_acc ->
        neighbor_node = scan_acc[neighbor_coord]

        # Air is effortless (0 cost), but rock cannot be traversed ("infinity")
        additional_distance = if neighbor_node.rock?, do: @infinity, else: 0

        # Calculate the new minimum distance to the neighbor
        new_distance = min(neighbor_node.distance, node.distance + additional_distance)

        # Put the updated neighbor back into the scan
        Map.put(scan_acc, neighbor_coord, %{neighbor_node | distance: new_distance})
      end)

    # Mark this node as visited
    next_unvisited = MapSet.delete(unvisited, coord)

    # Find the next node, which has the shortest overall distance
    next_coord = Enum.min_by(next_unvisited, fn coord -> next_scan[coord].distance end)

    # If the next minimum-distance node is rock, that means that we must have already visited ALL outside air nodes,
    # so we can bail out because we are done (and we explicitly do NOT want to visit any inside air nodes).
    if next_scan[next_coord].rock? do
      next_scan
    else
      # Recurse
      traverse(next_scan, next_coord, next_unvisited)
    end
  end

  # Filter out potential neighbor coords based on what has already been visited
  defp unvisited_neighbor_coords(coord, unvisited) do
    MapSet.intersection(neighbor_coords(coord), unvisited)
  end

  # Returns the number of faces in common between a coord and a big MapSet of potential neighbors
  defp count_shared_faces(rock_coord, air_coords) do
    rock_coord
    |> neighbor_coords()
    |> Enum.count(fn c -> Enum.member?(air_coords, c) end)
  end
end
