defmodule AdventOfCode.Day03 do
  @doc """
  ## Examples

    iex> Day03.part1(["R75,D30,R83,U83,L12,D49,R71,U7,L72", "U62,R66,U55,R34,D71,R55,D58,R83"])
    159

    iex> Day03.part1(["R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51","U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"])
    135
  """
  def part1(args) when is_list(args) do
    {x, y} =
      args
      |> Enum.map(&to_line_segments/1)
      |> IO.inspect
      |> find_crossings
      |> IO.inspect
      |> Enum.sort_by(fn {x, y} -> abs(x) + abs(y) end)
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
    to_line_segments(directions, {0, 0}, [])
  end

  def to_line_segments([], _, segments), do: Enum.reverse(segments)

  def to_line_segments([direction | rest], start, segments) do
    new_start =
      direction
      |> to_end_point(start)

    to_line_segments(rest, new_start, [{start, new_start} | segments])
  end

  def to_end_point(<<"U", number::binary>>, {x, y}), do: {x + String.to_integer(number), y}
  def to_end_point(<<"D", number::binary>>, {x, y}), do: {x - String.to_integer(number), y}
  def to_end_point(<<"L", number::binary>>, {x, y}), do: {x, y - String.to_integer(number)}
  def to_end_point(<<"R", number::binary>>, {x, y}), do: {x, y + String.to_integer(number)}

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

  # vertical a and horizontal b
  def find_crossing({{a, ays}, {a, aye}}, {{bxs, b}, {bxe, b}})
      when ays <= b and b <= aye and bxs <= a and a <= bxe,
      do: [{a, b}]

  # horizontal a and vertical b
  def find_crossing({{axs, a}, {axe, a}}, {{b, bys}, {b, bye}})
      when axs <= b and b <= axe and bys <= a and a <= bye,
      do: [{b, a}]

  # otherwise, they can't or don't cross
  def find_crossing(_, _), do: []

  def part2(args) do
  end
end
