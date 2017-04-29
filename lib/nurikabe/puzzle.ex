defmodule Nurikabe.Puzzle do
  @enforce_keys [:cells, :dimensions]
  defstruct [:cells, :dimensions]

  defmodule Sigil do
    def sigil_p(string, []) do
      {:ok, puzzle} =
        string
        |> String.trim
        |> Nurikabe.Puzzle.from_string

      puzzle
    end
  end

  def from_string(string) do
    rows = String.split(string, "\n", trim: true)
    num_rows = Enum.count(rows)
    row_lengths =
      Enum.map(rows, fn row ->
        row
        |> text_cells_from_row()
        |> Enum.count()
      end)

    case Enum.min_max(row_lengths, fn -> :no_rows_is_an_error end) do
      {num_cols, num_cols} ->
        cells_by_coordinate =
          rows
          |> Enum.with_index
          |> Enum.flat_map(fn {row_contents, row_num} ->
               row_contents
               |> text_cells_from_row()
               |> Enum.with_index
               |> Enum.map(fn {text, col_num} -> {{row_num, col_num}, cell_for_text(text)} end)
             end)
          |> Map.new

        puzzle = %__MODULE__{cells: cells_by_coordinate, dimensions: {num_rows, num_cols}}
        {:ok, puzzle}
      _ -> :error
    end
  end

  def pretty_print(%__MODULE__{cells: cells, dimensions: {num_rows, num_cols}}) do
    row_nums = (0..num_rows - 1)
    col_nums = (0..num_cols - 1)

    longest_cell_length =
      cells
      |> Stream.map(fn {_, v} -> v end)
      |> Stream.filter(&is_integer(&1))
      |> Stream.map(fn int -> int |> Integer.digits |> Enum.count end)
      |> Enum.max

    Enum.map(row_nums, fn row_num ->
      Enum.map(col_nums, fn col_num ->
        cells
        |> Map.fetch!({row_num, col_num})
        |> text_for_cell()
        |> String.pad_trailing(longest_cell_length)
      end)
      |> Enum.join
      |> String.trim
    end)
    |> Enum.join("\n")
  end

  defp text_cells_from_row(row) do
    ~r/[?.X]|\d+/
    |> Regex.scan(row)
    |> List.flatten
  end

  defp text_for_cell(num) when is_integer(num), do: Integer.to_string(num)
  defp text_for_cell(:white), do: "."
  defp text_for_cell(:black), do: "X"
  defp text_for_cell(:gray),  do: "?"

  defp cell_for_text("."), do: :white
  defp cell_for_text("X"), do: :black
  defp cell_for_text("?"), do: :gray
  defp cell_for_text(number_string) do
    {num, ""} = Integer.parse(number_string)
    num
  end
end
