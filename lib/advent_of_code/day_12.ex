defmodule AdventOfCode.Day12 do
  @doc """
  ## Examples
    iex> Day12.part1("<x=-8, y=-10, z=0>\\n<x=5, y=5, z=10>\\n<x=2, y=-7, z=3>\\n<x=9, y=-8, z=-3>", 100)
    {:energy, 1940}
  """
  def part1(args, steps \\ 1000) do
    {xstart, ystart, zstart} =
      args
      |> parse_input()

    xstate = run(xstart, steps)
    ystate = run(ystart, steps)
    zstate = run(zstart, steps)
    IO.inspect({:energy, energy(xstate, ystate, zstate)})
  end

  def part1() do
    "./data/day12.part1.txt"
    |> File.read!()
    |> part1()
  end

  @doc """
  ## Examples
    iex> Day12.part2("<x=-8, y=-10, z=0>\\n<x=5, y=5, z=10>\\n<x=2, y=-7, z=3>\\n<x=9, y=-8, z=-3>")
    4686774924
  """
  def part2(args) do
    {xstart, ystart, zstart} = parse_input(args)
    xcycle = find_period(xstart)
    ycycle = find_period(ystart)
    zcycle = find_period(zstart)
    lcm(xcycle, ycycle, zcycle)
  end

  def part2() do
    "./data/day12.part1.txt"
    |> File.read!()
    |> part2()
  end

  @doc """
  ## Examples
    iex> Day12.parse_input("<x=-8, y=-10, z=0>\\n<x=5, y=5, z=10>\\n<x=2, y=-7, z=3>\\n<x=9, y=-8, z=-3>")
    {{[-8, 5, 2, 9], [0, 0, 0, 0]}, {[-10, 5, -7, -8], [0, 0, 0, 0]}, {[0, 10, 3, -3], [0, 0, 0, 0]}}
  """
  def parse_input(text) do
    parse =
      text
      |> String.split(~r{\n}, trim: true)
      |> Enum.map(&parse_line/1)

    n = Enum.count(parse)

    {
      {collect_positions(parse, 0), List.duplicate(0, n)},
      {collect_positions(parse, 1), List.duplicate(0, n)},
      {collect_positions(parse, 2), List.duplicate(0, n)}
    }
  end

  def parse_line(line) do
    [_, x, y, z] = Regex.run(~r/x=(-?\d+),\s*y=(-?\d+),\s*z=(-?\d+)/, line)
    {String.to_integer(x), String.to_integer(y), String.to_integer(z)}
  end

  def collect_positions(list, pos) do
    list
    |> Enum.map(fn row ->
      elem(row, pos)
    end)
  end

  @doc """
  ## Examples
    iex> Day12.energy({[8, 13, -29, 16], [-7, 3, -3, 7]}, {[-12, 16, -11, -13], [3, 11, 7, 1]}, {[-9, -3, -1, 23], [0, -5, 4, 1]})
    1940
  """
  def energy({xpositions, _} = xstate, ystate, zstate) do
    n = Enum.count(xpositions)

    energies =
      for i <- 0..(n - 1) do
        potential_energy(i, xstate, ystate, zstate) * kinetic_energy(i, xstate, ystate, zstate)
      end

    Enum.sum(energies |> IO.inspect())
  end

  @doc """
  ## Examples
    iex> Day12.potential_energy(1, {[1,2,3], []}, {[2,-3,4], []}, {[0,1,2], []})
    6
  """
  def potential_energy(i, {xpos, _}, {ypos, _}, {zpos, _}) do
    abs(Enum.at(xpos, i)) + abs(Enum.at(ypos, i)) + abs(Enum.at(zpos, i))
  end

  @doc """
  ## Examples
    iex> Day12.kinetic_energy(1, {[], [1,2,3]}, {[], [2,-3,4]}, {[], [0,1,2]})
    6
  """
  def kinetic_energy(i, {_, xvel}, {_, yvel}, {_, zvel}) do
    abs(Enum.at(xvel, i)) + abs(Enum.at(yvel, i)) + abs(Enum.at(zvel, i))
  end

  @doc """
  ## Examples
    iex> Day12.run({[-8, 5, 2, 9], [0, 0, 0, 0]}, 100)
    {[8, 13, -29, 16], [-7, 3, -3, 7]}
  """
  def run(state, 0), do: state

  def run(state, count) do
    state
    |> step
    |> run(count - 1)
  end

  def step({positions, velocities}) do
    new_velocities = update_velocities(positions, velocities)
    new_positions = update_positions(positions, new_velocities)
    {new_positions, new_velocities}
  end

  def find_period(state) do
    # run one and see how many times we have to go
    find_period(state, step(state), 1)
  end

  def find_period(state, state, count), do: count

  def find_period(state1, state2, count) do
    find_period(state1, step(state2), count + 1)
  end

  @doc """
  ## Examples
    iex> Day12.update_velocities([-1, 0, 1], [1, 2, 3])
    [3, 2, 1]
  """
  def update_velocities(positions, velocities) do
    n = Enum.count(positions)

    for i <- 0..(n - 1) do
      new_vel(Enum.at(positions, i), Enum.at(velocities, i), List.delete_at(positions, i))
    end
  end

  @doc """
  ## Examples
    iex> Day12.update_positions([0, 1, 2], [-1, 2, 1])
    [-1, 3, 3]
  """
  def update_positions(positions, velocities) do
    n = Enum.count(positions)

    for i <- 0..(n - 1) do
      new_pos(Enum.at(positions, i), Enum.at(velocities, i))
    end
  end

  def new_pos(pos, vel), do: pos + vel

  @doc """
  ## Examples
    iex> Day12.vel_delta(3, [1, 4, 3, 5])
    1
    iex> Day12.vel_delta(-1, [0, 1])
    2
    iex> Day12.vel_delta(0, [-1, 1])
    0
    iex> Day12.vel_delta(1, [-1, 0])
    -2
  """
  def vel_delta(pos, others) do
    others
    |> Enum.map(fn
      x when x < pos -> -1
      x when x > pos -> 1
      x -> 0
    end)
    |> Enum.sum()
  end

  def new_vel(pos, vel, other_pos), do: vel + vel_delta(pos, other_pos)

  def lcm(a, b, c) do
    lcm(lcm(a, b), c)
  end

  def gcd(a, 0), do: a
  def gcd(0, b), do: b
  def gcd(a, b), do: gcd(b, rem(a, b))
  def lcm(0, 0), do: 0
  def lcm(a, b), do: trunc(a * b / gcd(a, b))
end
