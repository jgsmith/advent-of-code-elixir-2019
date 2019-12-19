defmodule AdventOfCode.Day05 do
  alias AdventOfCode.IntCode

  def part1(args) when is_tuple(args) do
    {:done, results} = args
    |> IntCode.new([1])
    |> IntCode.run

    results
  end

  def part1(rom) when is_list(rom) do
    rom
    |> List.to_tuple()
    |> part1()
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
    {:done, results} = args
      |> IntCode.new([5])
      |> IntCode.run

    results
  end

  def part2(rom) when is_list(rom) do
    rom
    |> List.to_tuple()
    |> part2()
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
