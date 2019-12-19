defmodule AdventOfCode.Day10 do
  @doc """
  ## Examples

    iex> Day10.part1(["......#.#.", "#..#.#....", "..#######.", ".#.#.###..", ".#..#.....",
    ...>   "..#....#.#", "#..#....#.", ".##.#..###", "##...#..#.", ".#....####"])
    {33, 5, 8}

    iex> Day10.part1([
    ...> ".#..##.###...#######",
    ...> "##.############..##.",
    ...> ".#.######.########.#",
    ...> ".###.#######.####.#.",
    ...> "#####.##.#.##.###.##",
    ...> "..#####..#.#########",
    ...> "####################",
    ...> "#.####....###.#.#.##",
    ...> "##.#################",
    ...> "#####.##.###..####..",
    ...> "..######..##.#######",
    ...> "####.##.####...##..#",
    ...> ".#####..#.######.###",
    ...> "##...#.##########...",
    ...> "#.##########.#######",
    ...> ".####.#.###.###.#.##",
    ...> "....##.##.###..#####",
    ...> ".#.#.###########.###",
    ...> "#.#.#.#####.####.###",
    ...> "###.##.####.##.#..##"])
    {210, 11, 13}
  """
  def part1(map) do
    # we want to look at each coordinate and calculate how many asteroids are visible from
    # that coordinate
    coords = asteroid_coords(map)

    coords
    |> Enum.map(fn {x, y} ->
        {
          visible_count(coords, x, y) - 1, # we don't count the origin
          x, y
        }
    end)
    |> Enum.sort
    |> Enum.reverse
    |> List.first
  end

  def part1() do
    "./data/day10.part1.txt"
    |> File.read!()
    |> String.split(~r{\n}, trim: true)
    |> part1()
  end

  @doc """
  ## Examples

    iex> Day10.part2([
    ...> ".#..##.###...#######",
    ...> "##.############..##.",
    ...> ".#.######.########.#",
    ...> ".###.#######.####.#.",
    ...> "#####.##.#.##.###.##",
    ...> "..#####..#.#########",
    ...> "####################",
    ...> "#.####....###.#.#.##",
    ...> "##.#################",
    ...> "#####.##.###..####..",
    ...> "..######..##.#######",
    ...> "####.##.####...##..#",
    ...> ".#####..#.######.###",
    ...> "##...#.##########...",
    ...> "#.##########.#######",
    ...> ".####.#.###.###.#.##",
    ...> "....##.##.###..#####",
    ...> ".#.#.###########.###",
    ...> "#.#.#.#####.####.###",
    ...> "###.##.####.##.#..##"])
    {130, {8, 2}}
  """
  def part2(map) do
    {_, cx, cy} = part1(map)

    coords = asteroid_coords(map)
    coords
    |> Enum.reject(fn
      {^cx, ^cy} -> true
      _ -> false
    end)
    |> Enum.map(fn {x, y} ->
      {normalize(y - cy, x - cx), {y - cy, x - cx}, distance(y - cy, x - cx), {x, y}}
    end)
    |> Enum.group_by(fn {theta, _, _, _} -> theta end)
    |> Enum.map(fn {_, r_list} ->
      [{_, {my, mx}, _, _} | _] = r_list
      {positive_theta(my, mx), Enum.sort(Enum.map(r_list, fn {_, _, r, p} -> {r, p} end))}
    end)
    |> Enum.sort
    |> find_asteroid(200)
  end

  def part2() do
    "./data/day10.part1.txt"
    |> File.read!()
    |> String.split(~r{\n}, trim: true)
    |> part2()
  end

  def find_asteroid([], _), do: nil

  def find_asteroid([{_, []} | rest], count), do: find_asteroid(rest, count)

  def find_asteroid([{_, [point | _]} | _], 1), do: point

  def find_asteroid([{theta, [point | points]} | rest], count) do
    find_asteroid(rest ++ [{theta, points}], count - 1)
  end

  def positive_theta(y, x) do
    theta = 90 - 180.0 * :math.atan2(-y, x) / :math.pi()
    cond do
      theta < 0.0 -> theta + 360.0
      theta >= 360.0 -> theta - 360.0
      true -> theta
    end
  end

  def distance(dy, dx), do: dy * dy + dx * dx

  def asteroid_coords(map) do
    asteroid_coords(map, 0, [])
  end

  def asteroid_coords([], _, acc), do: acc

  def asteroid_coords([row | rest], y, acc) do
    asteroid_coords(rest, y + 1, asteroid_coords(row, y, acc))
  end

  def asteroid_coords(row, y, acc) when is_binary(row) do
    asteroid_coords(row, 0, y, acc)
  end

  def asteroid_coords("", _, _, acc), do: acc

  def asteroid_coords(<< "#", rest::binary >>, x, y, acc) do
    asteroid_coords(rest, x + 1, y, [{x, y} | acc])
  end

  def asteroid_coords(<< _, rest::binary>>, x, y, acc) do
    asteroid_coords(rest, x + 1, y, acc)
  end

  def visible_count(coords, x, y) do
    coords
    |> Enum.map(fn
      {ax, ay} -> normalize(ay - y, ax - x)
    end)
    |> Enum.uniq
    |> Enum.count
  end

  def normalize(0, 0), do: {0, 0}

  def normalize(my, mx) do
    d = gcd(my, mx)
    {trunc(my / d), trunc(mx / d)}
  end

  def gcd(a, 0), do: abs(a)
   def gcd(0, b), do: abs(b)
   def gcd(a, b) when a < 0 or b < 0, do: gcd(abs(a), abs(b))
   def gcd(a, b), do: gcd(b, rem(a,b))
end
