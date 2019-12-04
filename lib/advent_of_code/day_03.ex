defmodule AdventOfCode.Day03 do
  @doc """
  ## Examples
    iex> Day03.part1(["R75,D30,R83,U83,L12,D49,R71,U7,L72", "U62,R66,U55,R34,D71,R55,D58,R83"])
    159
    iex> Day03.part1(["R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51","U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"])
    135
  """
  def part1(args) when is_list(args) do
    {{x, y}, _} =
      args
      |> Enum.map(&to_line_segments/1)
      |> find_crossings
      |> Enum.sort_by(fn {{x, y}, _} -> abs(x) + abs(y) end)
      |> List.first()

    abs(x) + abs(y)
  end

  def part1(filename) when is_binary(filename) do
    filename
    |> File.read!()
    |> String.split(~r{\s*\n\s*}, trim: true)
    |> part1
  end

  def to_line_segments(directions) when is_binary(directions) do
    directions
    |> String.split(~r{,}, trim: true)
    |> to_line_segments
  end

  def to_line_segments(directions) when is_list(directions) do
    to_line_segments(directions, {{0, 0}, 0}, [])
  end

  def to_line_segments([], _, segments), do: Enum.reverse(segments)

  def to_line_segments([direction | rest], {start, length}, segments) do
    {new_start, new_length} =
      direction
      |> to_end_point(start, length)

    to_line_segments(rest, {new_start, new_length}, [{start, new_start, length} | segments])
  end

  def to_end_point(<<"U", number::binary>>, {x, y}, length) do
    l = String.to_integer(number)
    {{x, y + l}, length + l}
  end

  def to_end_point(<<"D", number::binary>>, {x, y}, length) do
    l = String.to_integer(number)
    {{x, y - l}, length + l}
  end

  def to_end_point(<<"L", number::binary>>, {x, y}, length) do
    l = String.to_integer(number)
    {{x - l, y}, length + l}
  end

  def to_end_point(<<"R", number::binary>>, {x, y}, length) do
    l = String.to_integer(number)
    {{x + l, y}, length + l}
  end

  def find_crossings([a_lines, b_lines]) do
    # find all the places {x, y} that belong to both sets of lines
    Enum.flat_map(a_lines, fn a_line ->
      Enum.flat_map(b_lines, fn b_line ->
        find_crossing(a_line, b_line)
      end)
    end)
    |> Enum.reject(fn
      {0, 0} -> true
      _ -> false
    end)
  end

  defguard between(value, left, right)
           when (left < value and value < right) or (right < value and value < left)

  # vertical a and horizontal b
  def find_crossing({{a, ays}, {a, aye}, alength}, {{bxs, b}, {bxe, b}, blength})
      when between(b, ays, aye) and between(a, bxs, bxe) do
    [{{a, b}, {alength + distance(b, ays, aye), blength + distance(a, bxs, bxe)}}]
  end

  # horizontal a and vertical b
  def find_crossing({{axs, a}, {axe, a}, alength}, {{b, bys}, {b, bye}, blength})
      when between(b, axs, axe) and between(a, bys, bye) do
    [{{b, a}, {alength + distance(b, axs, axe), blength + distance(a, bys, bye)}}]
  end

  # otherwise, they can't or don't cross
  def find_crossing(_, _), do: []

  @doc """
  ## Examples
    iex> Day03.distance(-10, -12, 10)
    2
    iex> Day03.distance(-10, 10, -12)
    20
  """
  def distance(x, l, r) when l < x and x < r, do: x - l
  def distance(x, l, r) when r < x and x < l, do: l - x

  @doc """
  ## Examples
    iex> Day03.part2(["R75,D30,R83,U83,L12,D49,R71,U7,L72", "U62,R66,U55,R34,D71,R55,D58,R83"])
    610
    iex> Day03.part2(["R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51","U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"])
    410
  """
  def part2(args) when is_list(args) do
    {_, {a, b}} =
      args
      |> Enum.map(&to_line_segments/1)
      |> find_crossings
      |> Enum.sort_by(fn {_, {a, b}} -> a + b end)
      |> List.first()

    a + b
  end

  def part2(filename) when is_binary(filename) do
    filename
    |> File.read!()
    |> String.split(~r{\s*\n\s*}, trim: true)
    |> part2
  end
end
