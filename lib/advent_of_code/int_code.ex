defmodule AdventOfCode.IntCode do
  defstruct rom: {},
            ram: %{},
            pc: 0,
            rp: 0,
            stdin: [],
            stdout: []

  def new(rom, stdin \\ []) do
    %__MODULE__{rom: rom, stdin: stdin}
  end

  @doc """
  ## Examples
    iex> IntCode.run(IntCode.new({1002,4,3,4,33}))
    {:done, {[1002,4,3,4,99], []}}
    iex> IntCode.run(IntCode.new({3,0,4,0,99}, [123]))
    {:done, {[123,0,4,0,99], [123]}}
    iex> IntCode.run(IntCode.new({1101,100,-1,4,0}))
    {:done, {[1101,100,-1,4,99], []}}
    iex> IntCode.run(IntCode.new({3,9,8,9,10,9,4,9,99,-1,8}, [8]))
    {:done, {[3,9,8,9,10,9,4,9,99,1,8], [1]}}
    iex> IntCode.run(IntCode.new({3,9,8,9,10,9,4,9,99,-1,8}, [10]))
    {:done, {[3,9,8,9,10,9,4,9,99,0,8], [0]}}
    iex> IntCode.run(IntCode.new({3,3,1108,-1,8,3,4,3,99}, [8]))
    {:done, {[3,3,1108,1,8,3,4,3,99], [1]}}
    iex> IntCode.run(IntCode.new({3,3,1108,-1,8,3,4,3,99}, [10]))
    {:done, {[3,3,1108,0,8,3,4,3,99], [0]}}
    iex> IntCode.run(IntCode.new({104,1125899906842624,99}))
    {:done, {[104,1125899906842624,99], [1125899906842624]}}
    iex> IntCode.run(IntCode.new({1102,34915192,34915192,7,4,7,99,0}))
    {:done, {[1102,34915192,34915192,7,4,7,99,1219070632396864], [1219070632396864]}}
    iex> IntCode.run(IntCode.new({109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99}))
    {:done, {[109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99], [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99]}}
    iex> IntCode.run(IntCode.new({3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
    ...> 1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
    ...> 999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99}, [7]))
    {:done, {[3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
      1106,0,36,98,0,7,1002,21,125,20,4,20,1105,1,46,104,
      999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99], [999]}}
    iex> IntCode.run(IntCode.new({3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
    ...> 1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
    ...> 999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99}, [8]))
    {:done, {[3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
      1106,0,36,98,1000,8,1002,21,125,20,4,20,1105,1,46,104,
      999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99], [1000]}}
    iex> IntCode.run(IntCode.new({3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
    ...> 1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
    ...> 999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99}, [9]))
    {:done, {[3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
      1106,0,36,98,1001,9,1002,21,125,20,4,20,1105,1,46,104,
      999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99], [1001]}}
  """
  def run(machine) do
    case execute(machine, parsed(at(machine, pc(machine), 1))) do
      :done -> {:done, output_memory(machine)}
      :wait -> {:wait, machine}
      new_machine -> run(new_machine)
    end
  end

  def execute(_, {99, _, _, _}), do: :done

  def execute(machine, {1, mode1, mode2, mode3}) do
    result = at(machine, pc(machine) + 1, mode1) + at(machine, pc(machine) + 2, mode2)

    machine
    |> store(pc(machine) + 3, mode3, result)
    |> advance(:pc, 4)
  end

  def execute(machine, {2, mode1, mode2, mode3}) do
    result = at(machine, pc(machine) + 1, mode1) * at(machine, pc(machine) + 2, mode2)

    machine
    |> store(pc(machine) + 3, mode3, result)
    |> advance(:pc, 4)
  end

  def execute(machine, {3, mode1, _, _}) do
    case read(machine) do
      :wait ->
        :wait

      {value, new_machine} ->
        new_machine
        |> store(pc(new_machine) + 1, mode1, value)
        |> advance(:pc, 2)
    end
  end

  def execute(machine, {4, mode1, _, _}) do
    value = at(machine, pc(machine) + 1, mode1)
    # IO.inspect({:output, value})
    machine
    |> write(value)
    |> advance(:pc, 2)
  end

  def execute(machine, {5, mode1, mode2, _}) do
    case at(machine, pc(machine) + 1, mode1) do
      0 -> advance(machine, :pc, 3)
      _ -> set(machine, :pc, at(machine, pc(machine) + 2, mode2))
    end
  end

  def execute(machine, {6, mode1, mode2, _}) do
    case at(machine, pc(machine) + 1, mode1) do
      0 -> set(machine, :pc, at(machine, pc(machine) + 2, mode2))
      _ -> advance(machine, :pc, 3)
    end
  end

  def execute(machine, {7, mode1, mode2, mode3}) do
    result =
      if at(machine, pc(machine) + 1, mode1) < at(machine, pc(machine) + 2, mode2),
        do: 1,
        else: 0

    machine
    |> store(pc(machine) + 3, mode3, result)
    |> advance(:pc, 4)
  end

  def execute(machine, {8, mode1, mode2, mode3}) do
    result =
      if at(machine, pc(machine) + 1, mode1) == at(machine, pc(machine) + 2, mode2),
        do: 1,
        else: 0

    machine
    |> store(pc(machine) + 3, mode3, result)
    |> advance(:pc, 4)
  end

  def execute(machine, {9, mode1, _, _}) do
    machine
    |> advance(:rp, at(machine, pc(machine) + 1, mode1))
    |> advance(:pc, 2)
  end

  @doc """
  Returns a tuple with the opcode and address modes for the given instruction.
  ## Examples
    iex> IntCode.parsed(1002)
    {2, 0, 1, 0}
  """
  @spec parsed(term) :: {term, term, term, term}
  def parsed(instruction) do
    {
      # opcode
      rem(instruction, 100),
      # 1st mode
      rem(div(instruction, 100), 10),
      # 2st mode
      rem(div(instruction, 1000), 10),
      # 3st mode
      rem(div(instruction, 10000), 10)
    }
  end

  def pc(%{pc: value}), do: value
  def rp(%{rp: value}), do: value

  def advance(%{pc: value} = machine, :pc, offset) do
    %{machine | pc: value + offset}
  end

  def advance(%{rp: value} = machine, :rp, offset) do
    %{machine | rp: value + offset}
  end

  def set(machine, :pc, value), do: %{machine | pc: value}
  def write(%{stdout: stdout} = machine, value), do: %{machine | stdout: [value | stdout]}

  def read(%{stdin: []} = machine), do: :wait
  def read(%{stdin: [value | stdin]} = machine), do: {value, %{machine | stdin: stdin}}

  def provide(%{stdin: stdin} = machine, value), do: %{machine | stdin: stdin ++ [value]}

  def retrieve(%{stdout: [value | _]}), do: value
  def retrieve(_), do: nil

  defp output_memory(%{rom: rom, ram: ram, stdout: stdout} = machine) do
    top = max_addr(rom, ram)
    readout = for i <- 0..top, do: at(machine, i, 1)
    {readout, Enum.reverse(stdout)}
  end

  defp max_addr(rom, %{}), do: tuple_size(rom) - 1

  defp max_addr(rom, ram) do
    Enum.max([
      tuple_size(rom),
      Enum.max(Map.keys(ram)) + 1
    ]) - 1
  end

  defp store(machine, addr, 0, value) do
    store(machine, at(machine, addr, 1), 1, value)
  end

  defp store(%{ram: ram} = machine, addr, 1, value) do
    %{machine | ram: Map.put(ram, addr, value)}
  end

  defp store(%{ram: ram, rp: rp} = machine, addr, 2, value) do
    store(machine, at(machine, addr, 1) + rp, 1, value)
  end

  defp at(machine, addr, 0), do: at(machine, at(machine, addr, 1), 1)

  defp at(%{rom: rom, ram: ram} = _machine, addr, 1) do
    Map.get_lazy(ram, addr, fn ->
      if 0 <= addr and addr < tuple_size(rom), do: elem(rom, addr), else: 0
    end)
  end

  defp at(%{rp: rp} = machine, addr, 2), do: at(machine, at(machine, addr, 1) + rp, 1)
end
