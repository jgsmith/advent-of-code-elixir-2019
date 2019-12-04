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

  def part1(rom, replacements) when is_tuple(rom) do
    step(0, {rom, replacements})
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

  def step(pc, memory) do
    case at(pc, memory) do
      99 ->
        output_memory(memory)

      1 ->
        step(
          pc + 4,
          store_indirect(
            memory,
            pc + 3,
            at_indirect(pc + 1, memory) + at_indirect(pc + 2, memory)
          )
        )

      2 ->
        step(
          pc + 4,
          store_indirect(
            memory,
            pc + 3,
            at_indirect(pc + 1, memory) * at_indirect(pc + 2, memory)
          )
        )
    end
  end

  defp store({rom, ram}, addr, value) do
    {rom, Map.put(ram, addr, value)}
  end

  defp store_indirect(memory, addr, value) do
    store(memory, at(addr, memory), value)
  end

  defp at(addr, {rom, ram}) do
    Map.get_lazy(ram, addr, fn ->
      if addr < tuple_size(rom), do: elem(rom, addr), else: 0
    end)
  end

  defp at_indirect(addr, memory), do: at(at(addr, memory), memory)

  defp output_memory({rom, ram} = memory) do
    max_addr =
      Enum.max([
        tuple_size(rom),
        Enum.max(Map.keys(ram)) + 1
      ])

    for i <- 0..(max_addr - 1), do: at(i, memory)
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
