defmodule AdventOfCode.Day14 do
  @doc """
  ## Examples

    iex> Day14.part1(["10 ORE => 10 A","1 ORE => 1 B","7 A, 1 B => 1 C","7 A, 1 C => 1 D","7 A, 1 D => 1 E","7 A, 1 E => 1 FUEL"])
    31

    iex> Day14.part1(["157 ORE => 5 NZVS","165 ORE => 6 DCFZ","44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL","12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ","179 ORE => 7 PSHF","177 ORE => 5 HKGWZ","7 DCFZ, 7 PSHF => 2 XJWVT","165 ORE => 2 GPVTF","3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT"])
    13312

    iex> Day14.part1(["2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG","17 NVRVD, 3 JNWZP => 8 VPVL","53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL","22 VJHF, 37 MNCFX => 5 FWMGM","139 ORE => 4 NVRVD","144 ORE => 7 JNWZP","5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC","5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV","145 ORE => 6 MNCFX","1 NVRVD => 8 CXFTF","1 VJHF, 6 MNCFX => 4 RFSQX","176 ORE => 6 VJHF"])
    180697

    iex> Day14.part1(["171 ORE => 8 CNZTR","7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL","114 ORE => 4 BHXH","14 VRPVC => 6 BMBT","6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL","6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT","15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW","13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW","5 BMBT => 4 WPTQ","189 ORE => 9 KTJDG","1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP","12 VRPVC, 27 CNZTR => 2 XDBXC","15 KTJDG, 12 BHXH => 5 XCVML","3 BHXH, 2 VRPVC => 7 MZWV","121 ORE => 7 VRPVC","7 XCVML => 6 RJRHP","5 BHXH, 4 VRPVC => 5 LTCX"])
    2210736
  """
  def part1(lines) when is_list(lines) do
    lines
    |> Enum.map(&parse_line/1)
    |> Enum.into(%{})
    |> fuel_to_ore()
  end

  def part1() do
    "./data/day14.part1.txt"
    |> File.read!()
    |> String.split(~r{\n}, trim: true)
    |> part1()
  end

  @doc """
  ## Examples

    iex> Day14.part2(["157 ORE => 5 NZVS","165 ORE => 6 DCFZ","44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL","12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ","179 ORE => 7 PSHF","177 ORE => 5 HKGWZ","7 DCFZ, 7 PSHF => 2 XJWVT","165 ORE => 2 GPVTF","3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT"])
    82892753

    iex> Day14.part2(["2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG","17 NVRVD, 3 JNWZP => 8 VPVL","53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL","22 VJHF, 37 MNCFX => 5 FWMGM","139 ORE => 4 NVRVD","144 ORE => 7 JNWZP","5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC","5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV","145 ORE => 6 MNCFX","1 NVRVD => 8 CXFTF","1 VJHF, 6 MNCFX => 4 RFSQX","176 ORE => 6 VJHF"])
    5586022

    iex> Day14.part2(["171 ORE => 8 CNZTR","7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL","114 ORE => 4 BHXH","14 VRPVC => 6 BMBT","6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL","6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT","15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW","13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW","5 BMBT => 4 WPTQ","189 ORE => 9 KTJDG","1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP","12 VRPVC, 27 CNZTR => 2 XDBXC","15 KTJDG, 12 BHXH => 5 XCVML","3 BHXH, 2 VRPVC => 7 MZWV","121 ORE => 7 VRPVC","7 XCVML => 6 RJRHP","5 BHXH, 4 VRPVC => 5 LTCX"])
    460664
  """
  def part2(lines) when is_list(lines) do
    # just like part1, but binary search for optimum fuel level
    recipes =
      lines
      |> Enum.map(&parse_line/1)
      |> Enum.into(%{})

    ore = 1_000_000_000_000
    guess = div(ore, fuel_to_ore(recipes))
    find_total_fuel(recipes, div(guess, 2), guess, guess * 2, fuel_to_ore(recipes, guess), ore)
  end

  def part2() do
    "./data/day14.part1.txt"
    |> File.read!()
    |> String.split(~r{\n}, trim: true)
    |> part2()
  end

  # binary search
  def find_total_fuel(_, x, _, x, _, _), do: x
  def find_total_fuel(_, x, x, _, _, _), do: x
  def find_total_fuel(_, _, x, x, _, _), do: x

  def find_total_fuel(recipes, min, guess, max, ore_used, ore_available) do
    cond do
      ore_used > ore_available ->
        new_guess = div(min + guess, 2)

        find_total_fuel(
          recipes,
          min,
          new_guess,
          guess,
          fuel_to_ore(recipes, new_guess),
          ore_available
        )

      ore_used < ore_available ->
        new_guess = div(guess + max, 2)

        find_total_fuel(
          recipes,
          guess,
          new_guess,
          max,
          fuel_to_ore(recipes, new_guess),
          ore_available
        )

      true ->
        guess
    end
  end

  def parse_line(line) do
    [ingredients, result] = String.split(line, ~r{\s*=>\s*}, parts: 2)

    mapping =
      ingredients
      |> String.split(~r{\s*,\s*})
      |> Enum.map(fn ingredient ->
        [_, a, i] = Regex.run(~r{^(\d+)\s+(\S+)$}, ingredient)
        {i, String.to_integer(a)}
      end)
      |> Enum.into(%{})

    [_, a, i] = Regex.run(~r{^(\d+)\s+(\S+)$}, result)
    {i, {String.to_integer(a), mapping}}
  end

  # get topological ordering of ingredients from ORE to FUEL, and then reduce them in reverse order
  def recipe_order(recipes, acc \\ ["ORE"])

  def recipe_order(recipes, acc) do
    if map_size(recipes) == 0 do
      acc
    else
      acc_set = MapSet.new(acc)

      next_items =
        recipes
        |> Enum.filter(fn {_, {_, ingredients}} ->
          new_ingredients =
            ingredients
            |> Map.keys()
            |> MapSet.new()
            |> MapSet.difference(acc_set)

          MapSet.size(new_ingredients) == 0
        end)
        |> Enum.map(fn {name, _} -> name end)

      recipe_order(Map.drop(recipes, next_items), next_items ++ acc)
    end
  end

  def fuel_to_ore(recipes, amount \\ 1) do
    order = recipe_order(recipes)

    recipes
    |> recipe_order
    |> Enum.reduce(%{"FUEL" => amount}, fn
      "ORE", acc ->
        acc

      recipe, acc ->
        {modulus, ingredients} = Map.get(recipes, recipe)
        amount = Map.get(acc, recipe)
        multiplier = div(amount + modulus - 1, modulus)

        ingredients
        |> Enum.map(fn {ingredient, quantity} ->
          {ingredient, quantity * multiplier}
        end)
        |> Enum.reduce(acc, fn {component, amount}, acc ->
          Map.put(acc, component, amount + Map.get(acc, component, 0))
        end)
        |> Map.delete(recipe)
    end)
    |> Map.get("ORE")
  end
end
