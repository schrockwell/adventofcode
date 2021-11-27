defmodule AdventOfCode.Day04 do
  @behaviour AdventOfCode

  @required_fields Enum.sort(["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"])
  @all_fields Enum.sort(@required_fields ++ ["cid"])

  def run(input) do
    passports = parse_passports(input)

    answer_a = Enum.count(passports, &has_required_fields?/1)
    answer_b = Enum.count(passports, &valid_passport?/1)

    IO.puts("Answer A: #{answer_a}")
    IO.puts("Answer B: #{answer_b}")

    {to_string(answer_a), to_string(answer_b)}
  end

  defp parse_passports(input) do
    input
    |> Enum.chunk_by(&(&1 == ""))
    |> Enum.reject(&(&1 == [""]))
    |> Enum.map(fn lines ->
      lines
      |> Enum.join(" ")
      |> String.split(" ")
      |> Enum.map(fn key_value ->
        key_value
        |> String.split(":")
        |> List.to_tuple()
      end)
      |> Map.new()
    end)
  end

  defp valid_passport?(passport) do
    has_required_fields?(passport) &&
      valid_year?(passport, "byr", 1920..2002) &&
      valid_year?(passport, "iyr", 2010..2020) &&
      valid_year?(passport, "eyr", 2020..2030) &&
      valid_height?(passport) &&
      valid_hair_color?(passport) &&
      valid_eye_color?(passport) &&
      valid_passport_id?(passport)
  end

  defp has_required_fields?(passport) do
    Map.keys(passport) in [@required_fields, @all_fields]
  end

  defp valid_year?(passport, field, range) do
    String.to_integer(passport[field]) in range
  end

  defp valid_height?(%{"hgt" => <<cm::binary-3, "cm">>}) do
    String.to_integer(cm) in 150..193
  end

  defp valid_height?(%{"hgt" => <<inches::binary-2, "in">>}) do
    String.to_integer(inches) in 59..76
  end

  defp valid_height?(_), do: false

  defp valid_hair_color?(%{"hcl" => hcl}) do
    Regex.match?(~r/^#[0-9a-f]{6}$/, hcl)
  end

  defp valid_hair_color?(_), do: false

  defp valid_eye_color?(%{"ecl" => ecl})
       when ecl in ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"],
       do: true

  defp valid_eye_color?(_), do: false

  defp valid_passport_id?(%{"pid" => pid}) do
    Regex.match?(~r/^\d{9}$/, pid)
  end

  defp valid_passport_id?(_), do: false
end
