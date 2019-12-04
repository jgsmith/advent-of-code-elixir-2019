defmodule AdventOfCode.Day02 do
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

  def part1(args, replacements) when is_tuple(args) do
    args
    |> augment_with_replacements(replacements)
    |> part1(0, %{})
  end

  def part1(args, replacements) when is_list(args) do
    args
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

  def part1(rom, pc, ram) do
    case at(pc, rom, ram) do
      99 ->
        combine(rom, ram)

      1 ->
        part1(
          rom,
          pc + 4,
          Map.put(
            ram,
            at(pc + 3, rom, ram),
            at(at(pc + 1, rom, ram), rom, ram) + at(at(pc + 2, rom, ram), rom, ram)
          )
        )

      2 ->
        part1(
          rom,
          pc + 4,
          Map.put(
            ram,
            at(pc + 3, rom, ram),
            at(at(pc + 1, rom, ram), rom, ram) * at(at(pc + 2, rom, ram), rom, ram)
          )
        )
    end
  end

  def augment_with_replacements(tuple, mapping) do
    mapping
    |> Enum.reduce(tuple, fn {pos, val}, acc ->
      acc
      |> Tuple.insert_at(pos, val)
      |> Tuple.delete_at(pos + 1)
    end)
  end

  defp at(addr, rom, ram) do
    Map.get_lazy(ram, addr, fn ->
      if addr < tuple_size(rom), do: elem(rom, addr), else: 0
    end)
  end

  defp combine(rom, ram) do
    max_addr =
      Enum.max([
        tuple_size(rom),
        Enum.max(Map.keys(ram)) + 1
      ])

    for i <- 0..(max_addr - 1), do: at(i, rom, ram)
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
