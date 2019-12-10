defmodule AdventOfCode.Day07 do
  alias AdventOfCode.IntCode

  @doc """
  ## Examples

    iex> Day07.part1({3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0})
    43210

    iex> Day07.part1({3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0})
    54321

    iex> Day07.part1({3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0})
    65210
  """
  def part1(rom) when is_tuple(rom) do
    {output, setting} = find_optimal_setting(rom)
    IO.inspect({:signal, output})
    output
  end

  def part1(rom) when is_list(rom) do
    rom
    |> List.to_tuple()
    |> part1
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

  @doc """
  ## Examples

      iex> Day07.part2({3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,
      ...>   27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5})
      139629729
  """
  def part2(rom) when is_tuple(rom) do
    {output, setting} = find_optimal_feedback_setting(rom)
    IO.inspect({:signal, output, setting})
    output
  end

  def part2(rom) when is_list(rom) do
    rom
    |> List.to_tuple()
    |> part2
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

  def find_optimal_setting(rom) do
    [0, 1, 2, 3, 4]
    |> permutations
    |> Enum.map(fn [a, b, c, d, e] ->
      {:done, {_, [a_value | _]}} = IntCode.run(IntCode.new(rom, [a, 0]))
      {:done, {_, [b_value | _]}} = IntCode.run(IntCode.new(rom, [b, a_value]))
      {:done, {_, [c_value | _]}} = IntCode.run(IntCode.new(rom, [c, b_value]))
      {:done, {_, [d_value | _]}} = IntCode.run(IntCode.new(rom, [d, c_value]))
      {:done, {_, [e_value | _]}} = IntCode.run(IntCode.new(rom, [e, d_value]))

      {e_value, {a, b, c, d, e}}
    end)
    |> Enum.sort()
    |> Enum.reverse()
    |> List.first()
  end

  def find_optimal_feedback_setting(rom) do
    [5, 6, 7, 8, 9]
    |> permutations
    |> Enum.map(fn [a, b, c, d, e] ->
      {:done, {_, output}} =
        run_machines(
          IntCode.run(IntCode.new(rom, [a, 0])),
          IntCode.run(IntCode.new(rom, [b])),
          IntCode.run(IntCode.new(rom, [c])),
          IntCode.run(IntCode.new(rom, [d])),
          IntCode.run(IntCode.new(rom, [e]))
        )

      {List.last(output), {a, b, c, d, e}}
    end)
    |> Enum.sort()
    |> Enum.reverse()
    |> List.first()
  end

  def get_last_output({:wait, m}), do: IntCode.retrieve(m)
  def get_last_output({:done, {_, output}}), do: List.last(output)

  def run_machines({:wait, a}, {:wait, b}, {:wait, c}, {:wait, d}, {:wait, e}) do
    new_b = IntCode.run(IntCode.provide(b, IntCode.retrieve(a)))
    new_c = IntCode.run(IntCode.provide(c, get_last_output(new_b)))
    new_d = IntCode.run(IntCode.provide(d, get_last_output(new_c)))
    new_e = IntCode.run(IntCode.provide(e, get_last_output(new_d)))

    case new_e do
      {:done, _} = result ->
        result

      _ ->
        new_a = IntCode.run(IntCode.provide(a, get_last_output(new_e)))
        run_machines(new_a, new_b, new_c, new_d, new_e)
    end
  end

  def run_machines({:done, {_, a_output}} = a, {:wait, b}, {:wait, c}, {:wait, d}, {:wait, e}) do
    new_b = IntCode.run(IntCode.provide(b, List.last(a_output)))
    new_c = IntCode.run(IntCode.provide(c, get_last_output(new_b)))
    new_d = IntCode.run(IntCode.provide(d, get_last_output(new_c)))
    new_e = IntCode.run(IntCode.provide(e, get_last_output(new_d)))

    case new_e do
      {:done, _} = result ->
        result

      _ ->
        new_a = IntCode.run(IntCode.provide(a, get_last_output(new_e)))
        run_machines(new_a, new_b, new_c, new_d, new_e)
    end
  end

  @doc """
  ## Examples

    iex> Day07.permutations([1,2])
    [[1,2], [2,1]]
  """
  def permutations([]), do: []
  def permutations([x]), do: [[x]]

  def permutations(list) do
    for elem <- list, rest <- permutations(list -- [elem]) do
      [elem | rest]
    end
  end
end
