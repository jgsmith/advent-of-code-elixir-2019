defmodule AdventOfCode.Day06 do
  @doc """
  ## Examples

    iex> Day06.part1(["COM)B", "B)C", "C)D", "D)E", "E)F", "B)G", "G)H", "D)I", "E)J", "J)K", "K)L"])
    42
  """
  def part1(edges) when is_list(edges) do
    edges
    |> Enum.map(&parse_edge/1)
    |> build_graph
    |> count_orbits
  end

  def part1(filename) when is_binary(filename) do
    filename
    |> File.read!()
    |> String.trim()
    |> String.split(~r{\s*\n\s*}, trim: true)
    |> Enum.reject(fn s -> Regex.match?(~r/^\s*$/, s) end)
    |> part1()
  end

  @doc """
  ## Examples

    iex> Day06.part2(["COM)B", "B)C", "C)D", "D)E", "E)F", "B)G", "G)H", "D)I", "E)J", "J)K", "K)L", "K)YOU", "I)SAN"])
    4
  """
  def part2(edges) when is_list(edges) do
    graph =
      edges
      |> Enum.map(&parse_edge/1)
      |> build_graph

    you = :digraph.get_short_path(graph, "YOU", "COM") |> Enum.reverse()
    santa = :digraph.get_short_path(graph, "SAN", "COM") |> Enum.reverse()

    {you_prime, santa_prime} = find_first_difference(you, santa)

    Enum.count(you_prime) + Enum.count(santa_prime) - 2
  end

  def part2(filename) when is_binary(filename) do
    filename
    |> File.read!()
    |> String.trim()
    |> String.split(~r{\s*\n\s*}, trim: true)
    |> Enum.reject(fn s -> Regex.match?(~r/^\s*$/, s) end)
    |> part2()
  end

  def find_first_difference([x | you_rest], [x | santa_rest]) do
    find_first_difference(you_rest, santa_rest)
  end

  def find_first_difference(you, santa), do: {you, santa}

  def parse_edge({_, _} = edge), do: edge

  def parse_edge(edge) when is_binary(edge) do
    edge
    |> String.split(")", parts: 2)
    |> Enum.reverse()
    |> List.to_tuple()
  end

  def build_graph(edges) do
    Enum.reduce(edges, :digraph.new(), fn {orbiter, orbitee}, graph ->
      orbiter_v = :digraph.add_vertex(graph, orbiter)
      orbitee_v = :digraph.add_vertex(graph, orbitee)
      :digraph.add_edge(graph, orbiter_v, orbitee_v)
      graph
    end)
  end

  def count_orbits(graph) do
    graph
    |> :digraph.vertices()
    |> Enum.map(fn
      "COM" -> 0
      vertex -> Enum.count(:digraph.get_short_path(graph, vertex, "COM")) - 1
    end)
    |> Enum.sum()
  end
end
