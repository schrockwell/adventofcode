defmodule AdventOfCode.Day12 do
  @behaviour AdventOfCode

  defmodule Node do
    defstruct [:name, :big?, :visited?, :adjacent]
  end

  def run(input) do
    graph = parse_graph(input)
    paths = traverse(graph)

    answer_a = length(paths)

    {answer_a, "todo"}
  end

  # Returns a map of %{name => %Node{}}
  defp parse_graph(input) do
    input
    |> Enum.map(&String.split(&1, "-"))
    |> Enum.reduce(%{}, fn
      # Edges out of "start" are unidirectional
      ["start", name], map -> map |> put_edge("start", name)
      # Edges in to "end" are unidirectional
      [name, "end"], map -> map |> put_edge(name, "end")
      # Edges between all other nodes are BIDIRECTIONAL, so we we have TWO directed edges
      [name1, name2], map -> map |> put_edge(name1, name2) |> put_edge(name2, name1)
    end)
    |> Enum.map(fn {name, adjacent} ->
      big? = String.upcase(name) == name
      {name, %Node{name: name, adjacent: adjacent, big?: big?, visited?: false}}
    end)
    |> Map.new()
    |> Map.put("end", %Node{name: "end", adjacent: [], big?: false, visited?: false})
  end

  defp put_edge(map, from, to) do
    Map.update(map, from, [to], &[to | &1])
  end

  # Only big nodes and non-visited small nodes can be visited
  defp can_visit?(%Node{big?: true}), do: true
  defp can_visit?(%Node{big?: false, visited?: false}), do: true
  defp can_visit?(_), do: false

  # Update the node state
  defp visit_node(graph, name) do
    Map.update!(graph, name, fn n -> %{n | visited?: true} end)
  end

  # The main recursion for walking the graph
  def traverse(graph, name \\ "start", path \\ [], paths \\ [])

  def traverse(_graph, "end", path, paths) do
    # We've made it!
    [Enum.reverse(["end" | path]) | paths]
  end

  def traverse(graph, name, path, paths) do
    # Get our current node state
    node = graph[name]

    # Tack on our current node to the path
    path = [name | path]

    # Flag this node as visisted
    graph = visit_node(graph, name)

    # Find all adjacent nodes that are visitable
    next_names =
      node.adjacent
      |> Enum.map(&graph[&1])
      |> Enum.filter(&can_visit?/1)
      |> Enum.map(& &1.name)

    # Just keep swimming
    Enum.reduce(next_names, paths, fn next_name, paths_acc ->
      traverse(graph, next_name, path, paths_acc)
    end)
  end
end
