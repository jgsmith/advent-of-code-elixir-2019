defmodule AdventOfCode.Day11 do
  alias AdventOfCode.IntCode

  def part1(code, given_hull \\ %{})

  def part1(code, given_hull) when is_tuple(code) do
    hull = paint_hull(code, given_hull)
    IO.inspect(hull)
    IO.inspect(Enum.count(Map.keys(hull)))
  end

  def part1(code, given_hull) when is_list(code) do
    code
    |> List.to_tuple()
    |> part1(given_hull)
  end

  def part1(filename, given_hull) when is_binary(filename) do
    filename
    |> File.read!()
    |> String.trim()
    |> String.split(~r{\s*,\s*}, trim: true)
    |> Enum.reject(fn s -> Regex.match?(~r/^\s*$/, s) end)
    |> Enum.map(&String.to_integer/1)
    |> part1(given_hull)
  end

  def part1() do
    part1("./data/day11.part1.txt")
  end

  def part2(code, given_hull \\ %{{0, 0} => 1}) when is_tuple(code) do
    code
    |> paint_hull(given_hull)
    |> to_pgm()
  end

  def part2(code, given_hull) when is_list(code) do
    code
    |> List.to_tuple()
    |> part2(given_hull)
  end

  def part2(filename, given_hull) when is_binary(filename) do
    filename
    |> File.read!()
    |> String.trim()
    |> String.split(~r{\s*,\s*}, trim: true)
    |> Enum.reject(fn s -> Regex.match?(~r/^\s*$/, s) end)
    |> Enum.map(&String.to_integer/1)
    |> part2(given_hull)
  end

  def part2() do
    part2("./data/day11.part1.txt", %{{0, 0} => 1})
  end

  def paint_hull(code, hull \\ %{}) do
    robot = %{direction: :up, brain: IntCode.new(code), x: 0, y: 0}
    run_robot(robot, hull)
  end

  def run_robot(%{brain: brain} = robot, hull) do
    result =
      brain
      |> IntCode.provide(camera(robot, hull))
      |> IntCode.run()

    case result do
      {:done, _} ->
        hull

      {:wait, new_brain} ->
        [new_color, new_direction] = IntCode.retrieve(new_brain, 2)

        robot
        |> replace_brain(new_brain)
        |> turn_robot(new_direction)
        |> move_robot()
        |> run_robot(paint(robot, hull, new_color))
    end
  end

  def replace_brain(robot, brain), do: %{robot | brain: brain}

  def turn_robot(%{direction: :up} = robot, 0), do: %{robot | direction: :left}
  def turn_robot(%{direction: :up} = robot, 1), do: %{robot | direction: :right}
  def turn_robot(%{direction: :right} = robot, 0), do: %{robot | direction: :up}
  def turn_robot(%{direction: :right} = robot, 1), do: %{robot | direction: :down}
  def turn_robot(%{direction: :down} = robot, 0), do: %{robot | direction: :right}
  def turn_robot(%{direction: :down} = robot, 1), do: %{robot | direction: :left}
  def turn_robot(%{direction: :left} = robot, 0), do: %{robot | direction: :down}
  def turn_robot(%{direction: :left} = robot, 1), do: %{robot | direction: :up}

  def move_robot(%{direction: :up, y: y} = robot), do: %{robot | y: y + 1}
  def move_robot(%{direction: :down, y: y} = robot), do: %{robot | y: y - 1}
  def move_robot(%{direction: :left, x: x} = robot), do: %{robot | x: x - 1}
  def move_robot(%{direction: :right, x: x} = robot), do: %{robot | x: x + 1}

  def camera(%{x: x, y: y} = robot, hull) do
    Map.get(hull, {x, y}, 0)
  end

  def paint(%{x: x, y: y} = robot, hull, color) do
    Map.put(hull, {x, y}, color)
  end

  def to_pgm(hull) do
    {{minx, maxx}, {miny, maxy}} = hull_extents(hull)

    [
      "P2\n",
      to_string(maxx - minx + 1),
      " ",
      to_string(maxy - miny + 1),
      "\n",
      to_string(2),
      "\n",
      for y <- maxy..miny do
        [
          for x <- minx..maxx do
            v = at(hull, x, y)
            [to_string(v), " "]
          end,
          "\n"
        ]
      end
    ]
  end

  def at(hull, x, y) do
    Map.get(hull, {x, y}, 0)
  end

  def hull_extents(hull) do
    {xs, ys} =
      hull
      |> Map.keys()
      |> Enum.unzip()

    {Enum.min_max(xs), Enum.min_max(ys)}
  end
end
