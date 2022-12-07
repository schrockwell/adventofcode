defmodule AdventOfCode.Day07 do
  @behaviour AdventOfCode

  def run(input) do
    # Parse input into tuples {file, size} and dir names
    {files, dirs} =
      input
      |> String.split("\n")
      |> run_cmds()

    # Amend dirs to be tuples of {dir, size}
    dirs = calculate_dir_sizes(dirs, files)

    # Part A
    answer_a =
      dirs
      |> Enum.filter(fn {_dir, size} -> size <= 100_000 end)
      |> Enum.map(fn {_dir, size} -> size end)
      |> Enum.sum()

    # Part B
    used_space = calculate_dir_size("", files)
    unused_space = 70_000_000 - used_space

    {_dir, answer_b} =
      dirs
      |> Enum.sort_by(fn {_dir, size} -> size end)
      |> Enum.find(fn {_dir, size} -> unused_space + size > 30_000_000 end)

    {answer_a, answer_b}
  end

  ### "Executing" commands

  # Track the current working directory (cwd) and accumulate dirs and files as we see them

  defp run_cmds(commands, files \\ [], dirs \\ ["/"], cwd \\ "/")

  defp run_cmds(["$ cd .." | rest], files, dirs, cwd) do
    run_cmds(rest, files, dirs, cwd |> Path.split() |> Enum.drop(-1) |> Path.join())
  end

  defp run_cmds(["$ cd " <> next_dir | rest], files, dirs, cwd) do
    run_cmds(rest, files, dirs, Path.join(cwd, next_dir))
  end

  defp run_cmds(["$ ls" | rest], files, dirs, cwd) do
    # Find the ls output by splitting at the next command (starting with "$")
    {ls_output, next_cmds} =
      Enum.split_while(rest, fn cmd -> not String.starts_with?(cmd, "$") end)

    # Parse the dirs from the ls output (no size info yet)
    new_dirs =
      Enum.flat_map(ls_output, fn
        "dir " <> basename -> [Path.join(cwd, basename)]
        _ -> []
      end)

    # Parse the {file, size} tuples from the ls output
    new_files =
      ls_output
      |> Enum.reject(&String.starts_with?(&1, "dir "))
      |> Enum.map(fn file_ls ->
        [size, name] = String.split(file_ls)
        {Path.join(cwd, name), String.to_integer(size)}
      end)

    run_cmds(next_cmds, files ++ new_files, dirs ++ new_dirs, cwd)
  end

  defp run_cmds([], files, dirs, _cwd), do: {files, dirs}

  defp calculate_dir_sizes(dirs, files) do
    Enum.map(dirs, fn dir -> {dir, calculate_dir_size(dir, files)} end)
  end

  defp calculate_dir_size(dir, files) do
    files
    |> Enum.filter(fn {file, _size} -> String.starts_with?(file, dir <> "/") end)
    |> Enum.map(fn {_file, size} -> size end)
    |> Enum.sum()
  end
end
