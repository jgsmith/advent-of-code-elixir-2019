defmodule AdventOfCode.Day04 do
  @doc """
    However, they do remember a few key facts about the password:
    It is a six-digit number.
    The value is within the range given in your puzzle input.
    Two adjacent digits are the same (like 22 in 122345).
    Going from left to right, the digits never decrease; they only ever increase or stay the same (like 111123 or 135679).
    Other than the range rule, the following are true:
    111111 meets these criteria (double 11, never decreases).
    223450 does not meet these criteria (decreasing pair of digits 50).
    123789 does not meet these criteria (no double).
  ## Examples
    iex> Day04.part1(123456, 123467)
    1
    iex> Day04.part1(123456, 123477)
    2
  """
  def part1(first, last) do
    # we want to stream
    first
    |> until(last)
    |> Stream.map(&to_string/1)
    |> Enum.count(&valid_code?/1)
  end

  def until(first, last) do
    Stream.unfold(first, fn n ->
      if n > last, do: nil, else: {n, n + 1}
    end)
  end

  @doc """
  ## Examples
    iex> Day04.valid_code?("111111")
    true
    iex> Day04.valid_code?("223450")
    false
    iex> Day04.valid_code?("123789")
    false
  """
  def valid_code?(code) do
    String.length(code) == 6 and Regex.match?(~r{11|22|33|44|55|66|77|88|99}, code) and
      digits_not_decreasing?(code)
  end

  def digits_not_decreasing?(<<digit, rest::binary>>), do: digits_not_decreasing?(rest, digit)
  def digits_not_decreasing?(<<>>, _), do: true
  def digits_not_decreasing?(<<digit, _::binary>>, previous) when digit < previous, do: false
  def digits_not_decreasing?(<<digit, rest::binary>>, _), do: digits_not_decreasing?(rest, digit)

  def valid_code2?(code) do
    String.length(code) == 6 and digit_pair?(code) and digits_not_decreasing?(code)
  end

  @doc """
  ## Examples
    iex> Day04.valid_code2?("111111")
    false
    iex> Day04.valid_code2?("111122")
    true
    iex> Day04.valid_code2?("112244")
    true
    iex> Day04.valid_code2?("223450")
    false
    iex> Day04.valid_code2?("123789")
    false
  """
  def digit_pair?(code) do
    (Regex.match?(~r{11}, code) and !Regex.match?(~r{111}, code)) or
      (Regex.match?(~r{22}, code) and !Regex.match?(~r{222}, code)) or
      (Regex.match?(~r{33}, code) and !Regex.match?(~r{333}, code)) or
      (Regex.match?(~r{44}, code) and !Regex.match?(~r{444}, code)) or
      (Regex.match?(~r{55}, code) and !Regex.match?(~r{555}, code)) or
      (Regex.match?(~r{66}, code) and !Regex.match?(~r{666}, code)) or
      (Regex.match?(~r{77}, code) and !Regex.match?(~r{777}, code)) or
      (Regex.match?(~r{88}, code) and !Regex.match?(~r{888}, code)) or
      (Regex.match?(~r{99}, code) and !Regex.match?(~r{999}, code))
  end

  def part2(first, last) do
    first
    |> until(last)
    |> Stream.map(&to_string/1)
    |> Enum.count(&valid_code2?/1)
  end
end
