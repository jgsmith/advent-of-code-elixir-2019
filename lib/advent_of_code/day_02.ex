defmodule AdventOfCode.Day02 do
  alias AdventOfCode.IntCode

  @doc """
  ## Example

    iex> Day02.part1({1,0,0,0,99})
    [2,0,0,0,99]

    iex> Day02.part1({2,3,0,3,99})
    [2,3,0,6,99]

    iex> Day02.part1({2,4,4,5,99,0})
    [2,4,4,5,99,9801]

    iex> Day02.part1({1,1,1,4,99,5,6,0,99})
    [30,1,1,4,2,5,6,0,99]
  """
  def part1(args, replacements \\ %{})

  def part1(rom, replacements) when is_tuple(rom) do
    {:done, {memory, _}} = replacements
    |> Enum.reduce(IntCode.new(rom), fn {addr, value}, machine ->
      IntCode.set(machine, addr, value)
    end)
    |> IntCode.run

    memory
  end

  def part1(rom, replacements) when is_list(rom) do
    rom
    |> List.to_tuple()
    |> part1(replacements)
  end

  def part1(filename, replacements) when is_binary(filename) do
    filename
    |> File.read!()
    |> String.trim()
    |> String.split(~r{\s*,\s*}, trim: true)
    |> Enum.reject(fn s -> Regex.match?(~r/^\s*$/, s) end)
    |> Enum.map(&String.to_integer/1)
    |> part1(replacements)
  end

  @doc """
  ## Examples

    iex> Day02.part2({1,0,0,0,99}, 100)
    {0,4}
  """
  def part2(args, target) when is_tuple(args) do
    part2(args, target, 0, 0)
  end

  def part2(args, target) when is_list(args) do
    args
    |> List.to_tuple()
    |> part2(target)
  end

  def part2(filename, target) when is_binary(filename) do
    filename
    |> File.read!()
    |> String.trim()
    |> String.split(~r{\s*,\s*}, trim: true)
    |> Enum.reject(fn s -> Regex.match?(~r/^\s*$/, s) end)
    |> Enum.map(&String.to_integer/1)
    |> part2(target)
  end

  def part2(rom, target, x, y) do
    case part1(rom, %{1 => x, 2 => y}) do
      [^target | _] ->
        {x, y}

      _ ->
        if y == tuple_size(rom) do
          part2(rom, target, x + 1, 0)
        else
          part2(rom, target, x, y + 1)
        end
    end
  end
end
