defmodule AdventOfCode.Day05 do
  def part1(args) when is_tuple(args) do
    step(0, {args, %{}}, {[1], []})
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
    step(0, {args, %{}}, {[5], []})
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

  @doc """
  ## Examples
    iex> Day05.step(0, {{1002,4,3,4,33}, %{}})
    {[1002,4,3,4,99], []}
    iex> Day05.step(0, {{3,0,4,0,99}, %{}}, {[123], []})
    {[123,0,4,0,99], [123]}
    iex> Day05.step(0, {{1101,100,-1,4,0}, %{}})
    {[1101,100,-1,4,99], []}
    iex> Day05.step(0, {{3,9,8,9,10,9,4,9,99,-1,8}, %{}}, {[8], []})
    {[3,9,8,9,10,9,4,9,99,1,8], [1]}
    iex> Day05.step(0, {{3,9,8,9,10,9,4,9,99,-1,8}, %{}}, {[10], []})
    {[3,9,8,9,10,9,4,9,99,0,8], [0]}
    iex> Day05.step(0, {{3,3,1108,-1,8,3,4,3,99}, %{}}, {[8], []})
    {[3,3,1108,1,8,3,4,3,99], [1]}
    iex> Day05.step(0, {{3,3,1108,-1,8,3,4,3,99}, %{}}, {[10], []})
    {[3,3,1108,0,8,3,4,3,99], [0]}
    iex> Day05.step(0, {{3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
    ...> 1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
    ...> 999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99}, %{}}, {[7], []})
    {[3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
      1106,0,36,98,0,7,1002,21,125,20,4,20,1105,1,46,104,
      999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99], [999]}
    iex> Day05.step(0, {{3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
    ...> 1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
    ...> 999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99}, %{}}, {[8], []})
    {[3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
      1106,0,36,98,1000,8,1002,21,125,20,4,20,1105,1,46,104,
      999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99], [1000]}
    iex> Day05.step(0, {{3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
    ...> 1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
    ...> 999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99}, %{}}, {[9], []})
    {[3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
      1106,0,36,98,1001,9,1002,21,125,20,4,20,1105,1,46,104,
      999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99], [1001]}
  """
  def step(pc, memory, io \\ {[], []}) do
    case parsed(at(pc, 1, memory)) do
      {99, _, _, _} ->
        output_memory(memory, io)

      {1, mode1, mode2, mode3} ->
        step(
          pc + 4,
          store(
            memory,
            pc + 3,
            mode3,
            at(pc + 1, mode1, memory) + at(pc + 2, mode2, memory)
          ),
          io
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
          io
        )

      {3, mode1, _, _} ->
        {value, new_io} = read(io)
        step(pc + 2, store(memory, pc + 1, mode1, value), new_io)

      {4, mode1, _, _} ->
        value = at(pc + 1, mode1, memory)
        IO.inspect({:output, value})
        step(pc + 2, memory, write(io, value))

      {5, mode1, mode2, _} ->
        case at(pc + 1, mode1, memory) do
          0 -> step(pc + 3, memory, io)
          _ -> step(at(pc + 2, mode2, memory), memory, io)
        end

      {6, mode1, mode2, _} ->
        case at(pc + 1, mode1, memory) do
          0 -> step(at(pc + 2, mode2, memory), memory, io)
          _ -> step(pc + 3, memory, io)
        end

      {7, mode1, mode2, mode3} ->
        result = if at(pc + 1, mode1, memory) < at(pc + 2, mode2, memory), do: 1, else: 0
        step(pc + 4, store(memory, pc + 3, mode3, result), io)

      {8, mode1, mode2, mode3} ->
        result = if at(pc + 1, mode1, memory) == at(pc + 2, mode2, memory), do: 1, else: 0
        step(pc + 4, store(memory, pc + 3, mode3, result), io)
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

  def write({stdin, stdout} = _io, value), do: {stdin, [value | stdout]}
  def read({[value | stdin], stdout}), do: {value, {stdin, stdout}}

  defp output_memory({rom, ram} = memory, {_, stdout} = _io) do
    max_addr =
      Enum.max([
        tuple_size(rom),
        Enum.max(Map.keys(ram)) + 1
      ])

    readout = for i <- 0..(max_addr - 1), do: at(i, 1, memory)
    {readout, Enum.reverse(stdout)}
  end

  defp store(memory, addr, 0, value) do
    store(memory, at(addr, 1, memory), 1, value)
  end

  defp store({rom, ram}, addr, 1, value) do
    {rom, Map.put(ram, addr, value)}
  end

  defp at(addr, 0, memory), do: at(at(addr, 1, memory), 1, memory)

  defp at(addr, 1, {rom, ram}) do
    Map.get_lazy(ram, addr, fn ->
      if 0 <= addr and addr < tuple_size(rom), do: elem(rom, addr), else: 0
    end)
  end
end
