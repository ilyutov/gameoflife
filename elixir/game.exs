defmodule Game do
  @live "\u25FD"
  @dead "\u25FE"
  @clear "\e[1A\e[K"

  defmodule World do
    @enforce_keys [:dim, :state]
    defstruct [:dim, :state]
  end

  def run do
    world = init(32)

    Stream.interval(100)
    |> Stream.scan(world, &step/2)
    |> Stream.run()
  end

  defp init(dim) do
    state = Stream.repeatedly(fn -> Enum.random([true, false]) end) |> Enum.take(dim * dim)

    %World{
      state: state,
      dim: dim
    }
  end

  defp step(step, %World{dim: dim} = world) do
    clear(step, dim)
    render(world)
    next(world)
  end

  defp next(%World{dim: dim, state: state} = world) do
    new_state =
      state
      |> Stream.with_index()
      |> Stream.map(fn {cell, index} ->
        {row, col} = ltos(index, dim)
        n = live_neighbours(world, row, col)
        {cell, n}
      end)
      |> Enum.map(fn
        {true, n} -> n == 2 || n == 3
        {false, n} -> n == 3
      end)

    %World{dim: dim, state: new_state}
  end

  defp clear(0, _), do: nil

  defp clear(_, dim) do
    IO.write(String.duplicate(@clear, dim))
  end

  defp render(%World{dim: dim, state: state}) do
    state
    |> Stream.with_index()
    |> Stream.each(fn
      {true, _i} -> IO.write(@live)
      {false, _i} -> IO.write(@dead)
    end)
    |> Stream.each(fn {_cell, i} ->
      {_row, col} = ltos(i, dim)
      if col == dim - 1, do: IO.write("\n")
    end)
    |> Stream.run()
  end

  defp live_neighbours(world, i, j) do
    [
      get_cell(world, i - 1, j - 1),
      get_cell(world, i - 1, j),
      get_cell(world, i - 1, j + 1),
      get_cell(world, i, j - 1),
      get_cell(world, i, j + 1),
      get_cell(world, i + 1, j - 1),
      get_cell(world, i + 1, j),
      get_cell(world, i + 1, j + 1)
    ]
    |> Enum.count(&Function.identity/1)
  end

  defp get_cell(%World{dim: dim, state: state}, i, j) do
    Enum.at(
      state,
      stol(i, j, dim)
    )
  end

  # linear <> square
  defp ltos(i, dim), do: {div(i, dim), rem(i, dim)}
  defp stol(i, j, dim) when i < 0, do: stol(i + dim, j, dim)
  defp stol(i, j, dim) when j < 0, do: stol(i, j + dim, dim)
  defp stol(i, j, dim), do: rem(i, dim) * dim + rem(j, dim)
end

Game.run()
