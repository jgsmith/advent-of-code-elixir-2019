defmodule AdventOfCode.Day13 do
  alias AdventOfCode.IntCode

  def part1(args) when is_tuple(args) do
    run(args, %{})
  end

  def part1(args) when is_list(args) do
    args
    |> List.to_tuple()
    |> part1()
    |> Map.values()
    |> Enum.count(fn
      2 -> true
      _ -> false
    end)
  end

  def part1() do
    "./data/day13.part1.txt"
    |> File.read!()
    |> String.trim()
    |> String.split(~r{\s*,\s*}, trim: true)
    |> Enum.reject(fn s -> Regex.match?(~r/^\s*$/, s) end)
    |> Enum.map(&String.to_integer/1)
    |> part1()
  end

  def part2(args) when is_tuple(args) do
    args
    |> IntCode.new()
    |> IntCode.poke(0, 2)
    |> play(%{})
  end

  def part2(args) when is_list(args) do
    args
    |> List.to_tuple()
    |> part2()
  end

  def part2() do
    "./data/day13.part1.txt"
    |> File.read!()
    |> String.trim()
    |> String.split(~r{\s*,\s*}, trim: true)
    |> Enum.reject(fn s -> Regex.match?(~r/^\s*$/, s) end)
    |> Enum.map(&String.to_integer/1)
    |> part2()
  end

  @spec find_ball(map) :: {integer, integer}
  def find_ball(screen) do
    screen
    |> Enum.find(fn
      {_, 4} -> true
      _ -> false
    end)
    |> elem(0)
    |> elem(0)
  end

  def find_paddle(screen) do
    screen
    |> Enum.find(fn
      {_, 3} -> true
      _ -> false
    end)
    |> elem(0)
    |> elem(0)
  end

  def play(machine, screen) do
    case run(machine, screen) do
      {machine, screen} ->
        # we want input!!
        b = find_ball(screen)
        p = find_paddle(screen)

        j =
          cond do
            b < p -> -1
            b > p -> 1
            true -> 0
          end

        machine
        |> IntCode.provide(j)
        |> play(screen)

      %{} = screen ->
        Map.get(screen, {-1, 0})
    end
  end

  def run(code, screen) when is_tuple(code) do
    code
    |> IntCode.new()
    |> run(screen)
  end

  def run(machine, screen) do
    result = IntCode.run(machine)

    case result do
      {:done, {_, output}} ->
        output
        |> Enum.chunk_every(3)
        |> Enum.reduce(screen, fn [x, y, type], tty ->
          draw(tty, x, y, type)
        end)

      {:wait, machine} ->
        {output, new_machine} = IntCode.retrieve_and_clear(machine)

        new_screen =
          output
          |> Enum.chunk_every(3)
          |> Enum.reduce(screen, fn [x, y, type], tty ->
            draw(tty, x, y, type)
          end)

        {new_machine, new_screen}

      otherwise ->
        otherwise |> IO.inspect()
    end
  end

  def draw(screen, x, y, type) do
    Map.put(screen, {x, y}, type)
  end
end
