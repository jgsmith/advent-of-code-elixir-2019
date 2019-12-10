defmodule AdventOfCode.Day09 do
  alias AdventOfCode.IntCode

  def part1(args) when is_tuple(args) do
    args
    |> IntCode.new([1])
    |> IntCode.step()
    |> IO.inspect()
  end

  def part1(args) when is_list(args) do
    args
    |> List.to_tuple()
    |> part1
  end

  def part1() do
    part1("./data/day09.part1.txt")
  end

  def part1(filename) when is_binary(filename) do
    filename
    |> File.read!()
    |> String.trim()
    |> String.split(~r{\s*,\s*}, trim: true)
    |> Enum.reject(fn s -> Regex.match?(~r/^\s*$/, s) end)
    |> Enum.map(&String.to_integer/1)
    |> part1()
  end

  def part2(args) when is_tuple(args) do
    args
    |> IntCode.new([2])
    |> IntCode.step()
    |> IO.inspect()
  end

  def part2(args) when is_list(args) do
    args
    |> List.to_tuple()
    |> part2
  end

  def part2() do
    part2("./data/day09.part1.txt")
  end

  def part2(filename) when is_binary(filename) do
    filename
    |> File.read!()
    |> String.trim()
    |> String.split(~r{\s*,\s*}, trim: true)
    |> Enum.reject(fn s -> Regex.match?(~r/^\s*$/, s) end)
    |> Enum.map(&String.to_integer/1)
    |> part2()
  end
end
