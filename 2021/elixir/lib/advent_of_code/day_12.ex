defmodule AdventOfCode.Day12 do
  @behaviour AdventOfCode

  defmodule Node do
    defstruct [:name, :big?, :visits, :adjacent]
  end

  def run(input) do
    graph = parse_graph(input)

    answer_a = graph |> traverse(:single) |> length()
    answer_b = graph |> traverse(:double) |> length()

    {answer_a, answer_b}
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
      {name, %Node{name: name, adjacent: adjacent, big?: big?, visits: 0}}
    end)
    |> Map.new()
    |> Map.put("end", %Node{name: "end", adjacent: [], big?: false, visits: 0})
  end

  defp put_edge(map, from, to) do
    Map.update(map, from, [to], &[to | &1])
  end

  # Only big nodes and non-visited small nodes can be visited
  defp can_visit?(mode, graph, name) when is_binary(name),
    do: can_visit?(mode, graph, graph[name])

  defp can_visit?(_mode, _graph, %Node{name: "start"}), do: false
  defp can_visit?(_mode, _graph, %Node{big?: true}), do: true
  defp can_visit?(_mode, _graph, %Node{big?: false, visits: 0}), do: true

  # Part 1: In :single mode, small nodes can only be visisted once
  defp can_visit?(:single, _graph, %Node{big?: false, visits: 1}), do: false

  # Part 2: In :double mode, one small node may be visited twice.
  # This is VERY inefficient and we should not be looping here, but instead
  # storing the doubled-up room name on the graph data structure so we don't
  # have to look it up every time
  defp can_visit?(:double, graph, %Node{big?: false, visits: 1}) do
    graph
    |> Enum.filter(fn {_, node} -> not node.big? end)
    |> Enum.all?(fn {_, node} -> node.visits < 2 end)
  end

  defp can_visit?(:double, _graph, %Node{big?: false, visits: 2}), do: false

  # Update the node state
  defp visit_node(graph, name) do
    Map.update!(graph, name, fn n -> %{n | visits: n.visits + 1} end)
  end

  # The main recursion for walking the graph
  def traverse(graph, mode \\ :single, name \\ "start", path \\ [], paths \\ [])

  def traverse(_graph, _mode, "end", path, paths) do
    # We've made it!
    [Enum.reverse(["end" | path]) | paths]
  end

  def traverse(graph, mode, name, path, paths) do
    # Get our current node state
    node = graph[name]

    # Tack on our current node to the path
    path = [name | path]

    # Flag this node as visisted
    graph = visit_node(graph, name)

    # Find all adjacent nodes that are visitable
    next_names = Enum.filter(node.adjacent, fn name -> can_visit?(mode, graph, name) end)

    # Just keep swimming
    Enum.reduce(next_names, paths, fn next_name, paths_acc ->
      traverse(graph, mode, next_name, path, paths_acc)
    end)
  end
end
