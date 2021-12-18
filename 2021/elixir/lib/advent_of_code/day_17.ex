defmodule AdventOfCode.Day17 do
  @behaviour AdventOfCode

  defmodule Projectile do
    defstruct x: 0, y: 0, x_vel: nil, y_vel: nil
  end

  def run([input]) do
    {_x_range, _y_range} = target = parse_target(input)

    hits = find_hits(target)

    answer_a = find_max_y_hit(hits)
    answer_b = length(hits)

    {answer_a, answer_b}
  end

  defp parse_target(input) do
    # e.g. "target area: x=282..314, y=-80..-45"
    [_, x1, x2, y1, y2] =
      Regex.run(~r/target area: x=(\-?\d+)\.\.(\-?\d+), y=(\-?\d+)\.\.(\-?\d+)/, input)

    {String.to_integer(x1)..String.to_integer(x2), String.to_integer(y1)..String.to_integer(y2)}
  end

  defp fire(projectile, target, steps \\ []) do
    next_projectile = step(projectile)
    steps = [next_projectile | steps]

    case position(next_projectile, target) do
      :enroute -> fire(next_projectile, target, steps)
      :hit! -> {:hit!, Enum.reverse(steps)}
      :miss! -> miss_reason(projectile, next_projectile, target)
    end
  end

  defp step(projectile) do
    %Projectile{
      x: projectile.x + projectile.x_vel,
      y: projectile.y + projectile.y_vel,
      x_vel: max(projectile.x_vel - 1, 0),
      y_vel: projectile.y_vel - 1
    }
  end

  defp position(%{x: x, y: y} = _projectile, {x_range, y_range} = _target) do
    cond do
      x in x_range and y in y_range -> :hit!
      x > x_range.last or y < y_range.first -> :miss!
      true -> :enroute
    end
  end

  defp miss_reason(projectile, _next_projectile, {x_range, y_range} = _target) do
    # I'm not proud of this 10x factor here because I don't fully understand it,
    # but it DOES work
    cond do
      projectile.x_vel > 10 * Range.size(x_range) -> {:miss!, :x_vel}
      projectile.y_vel < -10 * Range.size(y_range) -> {:miss!, :y_vel}
      true -> {:miss!, :other}
    end
  end

  defp find_hits(target) do
    max_x_vel = find_max_velocity(target, :x_vel) |> IO.inspect(label: "max_x_vel")
    min_y_vel = find_max_velocity(target, :y_vel, 0, -1) |> IO.inspect(label: "min_y_vel")
    max_y_vel = find_max_velocity(target, :y_vel) |> IO.inspect(label: "max_y_vel")

    for x_vel <- 1..max_x_vel, y_vel <- min_y_vel..max_y_vel, reduce: [] do
      hits ->
        %Projectile{x_vel: x_vel, y_vel: y_vel}
        |> fire(target)
        |> case do
          {:hit!, steps} -> [steps | hits]
          _ -> hits
        end
    end
  end

  defp find_max_velocity(target, ord, velocity \\ 1, step \\ 1) when ord in [:x_vel, :y_vel] do
    %Projectile{x_vel: 0, y_vel: 0}
    |> Map.put(ord, velocity)
    |> fire(target)
    |> case do
      {:miss!, ^ord} -> velocity - 1
      _ -> find_max_velocity(target, ord, velocity + step, step)
    end
  end

  defp find_max_y_hit(hits) do
    hits
    |> Enum.map(fn steps ->
      steps
      |> Enum.map(& &1.y)
      |> Enum.max()
    end)
    |> Enum.max()
  end
end
