defmodule AdventOfCode.Day05 do
  def part1(args) when is_tuple(args) do
    step(0, {args, %{}}, [1])
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

  def part2(args) do
  end

  @doc """
  ## Examples

    iex> Day05.step(0, {{1002,4,3,4,33}, %{}})
    {[1002,4,3,4,99], []}

    iex> Day05.step(0, {{3,0,4,0,99}, %{}}, [123], [])
    {[123,0,4,0,99], [123]}

    iex> Day05.step(0, {{1101,100,-1,4,0}, %{}}, [], [])
    {[1101,100,-1,4,99], []}
  """
  def step(pc, memory, stdin \\ [], stdout \\ []) do
    case parsed(at(pc, 1, memory)) do
      {99, _, _, _} ->
        output_memory(memory, stdout)

      {1, mode1, mode2, mode3} ->
        step(
          pc + 4,
          store(
            memory,
            pc + 3,
            mode3,
            at(pc + 1, mode1, memory) + at(pc + 2, mode2, memory)
          ),
          stdin,
          stdout
        )

      {2, mode1, mode2, mode3} ->
        step(
          pc + 4,
          store(
            memory,
            pc + 3,
            mode3,
            at(pc + 1, mode1, memory) * at(pc + 2, mode2, memory)
          ),
          stdin,
          stdout
        )

      {3, mode1, _, _} ->
        [value | new_stdin] = stdin

        step(
          pc + 2,
          store(memory, pc + 1, mode1, value),
          new_stdin,
          stdout
        )

      {4, mode1, _, _} ->
        value = at(pc + 1, mode1, memory)
        IO.inspect({:output, value})
        step(pc + 2, memory, stdin, [value | stdout])
    end
  end

  @doc """
  Returns a tuple with the opcode and address modes for the given instruction.

  ## Examples

    iex> Day05.parsed(1002)
    {2, 0, 1, 0}
  """
  def parsed(instruction) do
    # opcode
    {
      rem(instruction, 100),
      # 1st mode
      rem(div(instruction, 100), 10),
      # 2st mode
      rem(div(instruction, 1000), 10),
      # 3st mode
      rem(div(instruction, 10000), 10)
    }
  end

  defp output_memory({rom, ram} = memory, stdout) do
    max_addr =
      Enum.max([
        tuple_size(rom),
        Enum.max(Map.keys(ram)) + 1
      ])

    readout = for i <- 0..(max_addr - 1), do: at(i, 1, memory)
    {readout, Enum.reverse(stdout)}
  end

  @doc """
  Storage modes:
    0 - position
    1 - immediate
  """
  defp store({rom, ram}, addr, 1, value) do
    {rom, Map.put(ram, addr, value)}
  end

  defp store(memory, addr, 0, value) do
    store(memory, at(addr, 1, memory), 1, value)
  end

  @doc """
  Address modes:
    0 - position
    1 - immediate
  """
  defp at(addr, 1, {rom, ram}) do
    Map.get_lazy(ram, addr, fn ->
      if addr < tuple_size(rom), do: elem(rom, addr), else: 0
    end)
  end

  defp at(addr, 0, memory), do: at(at(addr, 1, memory), 1, memory)
end
