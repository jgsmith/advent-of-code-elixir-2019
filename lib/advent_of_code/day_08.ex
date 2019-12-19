defmodule AdventOfCode.Day08 do
  @doc """
  ## Examples

    iex> Day08.part1("123456789012", width: 3, height: 2)
    {0, 1}
  """
  def part1(raw, opts) do
    raw
    |> raw_to_layers(opts)
    |> Enum.map(&calculate_indices/1)
    |> Enum.sort
    |> List.first
  end

  def part1() do
    "./data/day08.part1.txt"
    |> File.read!()
    |> String.trim()
    |> part1(width: 25, height: 6)
  end

  @doc """
  ## Examples

    iex> Day08.part2("0222112222120000", width: 2, height: 2)
    ['01', '10']
  """
  def part2(raw, opts) do
    width = Keyword.fetch!(opts, :width)

    raw
    |> raw_to_layers(opts)
    |> Enum.reduce(&combine_layers/2)
    |> IO.inspect
    |> Enum.chunk_every(width)
  end

  def part2() do
    "./data/day08.part1.txt"
    |> File.read!()
    |> String.trim()
    |> part2(width: 25, height: 6)
  end

  def raw_to_layers(raw, opts) when is_binary(raw) do
    width = Keyword.fetch!(opts, :width)
    height = Keyword.fetch!(opts, :height)

    # we have width*height digits in each layer
    # so we split raw on that
    raw
    |> String.to_charlist
    |> Enum.chunk_every(width * height)
  end

  def raw_to_layers(raw, opts) when is_list(raw) do
    width = Keyword.fetch!(opts, :width)
    height = Keyword.fetch!(opts, :height)

    # we have width*height digits in each layer
    # so we split raw on that
    raw
    |> Enum.chunk_every(width * height)
  end

  def calculate_indices(charlist) do
    {
      Enum.count(charlist, &is_zero/1),
      Enum.count(charlist, &is_one/1) * Enum.count(charlist, &is_two/1)
    }
  end

  def combine_layers(layer, acc) do
    Enum.map(Enum.zip(layer, acc), &combine_pixels/1)
  end

  def combine_pixels({x, ?2}), do: x
  def combine_pixels({_, x}), do: x

  defp is_zero(?0), do: true
  defp is_zero(_), do: false

  defp is_one(?1), do: true
  defp is_one(_), do: false

  defp is_two(?2), do: true
  defp is_two(_), do: false
end
