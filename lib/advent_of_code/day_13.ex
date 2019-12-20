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

  def part2(args) do
  end

  def run(code, screen) do
    result =
      code
      |> IntCode.new()
      |> IntCode.run()

    case result do
      {:done, {_, output}} ->
        output
        |> Enum.chunk_every(3)
        |> Enum.reduce(screen, fn [x, y, type], tty ->
          draw(tty, x, y, type)
        end)

      otherwise ->
        IO.inspect(otherwise)
    end
  end

  def draw(screen, x, y, type) do
    Map.put(screen, {x, y}, type)
  end
end
