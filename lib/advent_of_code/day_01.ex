defmodule AdventOfCode.Day01 do
  @doc """
  ## Examples

    iex> Day01.part1([12])
    2

    iex> Day01.part1([14])
    2

    iex> Day01.part1([1969])
    654

    iex> Day01.part1([100756])
    33583
  """
  def part1(input) when is_list(input) do
    input
    |> Enum.map(&part1/1)
    |> Enum.sum()
  end

  def part1(filename) when is_binary(filename) do
    filename
    |> File.read!()
    |> String.split(~r{\s*\n\s*})
    |> Enum.reject(fn s -> Regex.match?(~r/^\s*$/, s) end)
    |> Enum.map(&String.to_integer/1)
    |> part1
  end

  def part1(mass) when is_number(mass) do
    fuel = floor(mass / 3) - 2

    if fuel < 0, do: 0, else: fuel
  end

  @doc """
  ## Examples

    iex> Day01.part2([14])
    2

    iex> Day01.part2([1969])
    966

    iex> Day01.part2([100756])
    50346
  """
  def part2(input) when is_list(input) do
    input
    |> Enum.map(&part2/1)
    |> Enum.sum()
  end

  def part2(filename) when is_binary(filename) do
    filename
    |> File.read!()
    |> String.split(~r{\s*\n\s*})
    |> Enum.reject(fn s -> Regex.match?(~r/^\s*$/, s) end)
    |> Enum.map(&String.to_integer/1)
    |> part2
  end

  def part2(mass) when is_number(mass), do: part2(mass, 0)
  def part2(mass, acc) when mass < 3, do: acc

  def part2(mass, acc) do
    fuel = floor(mass / 3) - 2

    if fuel <= 0 do
      acc
    else
      part2(fuel, acc + fuel)
    end
  end
end
