defmodule Tabular do
  @moduledoc """
  Documentation for Tabular.
  """

  @row_splitter_re ~r/^\s*[|+]--[-+|]+$/

  def to_list_of_maps(ascii_table) do
    [headers | rows] = to_list_of_lists(ascii_table)
    headers_as_atoms = Enum.map(headers, &String.to_atom(&1))

    rows
    |> Enum.map(fn row ->
      Enum.zip(headers_as_atoms, row)
      |> Map.new()
    end)
  end

  def to_list_of_lists_no_hd(ascii_table) do
    ascii_table
    |> to_list_of_lists
    |> Enum.drop(1)
  end

  def to_list_of_lists(ascii_table) do
    ascii_table
    |> lines()
    |> cell_line_groups()
    |> trimmed_and_grouped_cell_contents()
    |> folded_cell_contents()
    |> specials()
  end

  def lines(ascii_table) do
    ascii_table
    |> String.trim()
    |> String.split("\n")
  end

  def cell_line_groups(lines) do
    lines
    |> Enum.chunk_by(fn line ->
      Regex.match?(@row_splitter_re, line)
    end)
    |> Enum.filter(fn group ->
      !(length(group) == 1 &&
          Regex.match?(@row_splitter_re, hd(group)))
    end)
  end

  def trimmed_and_grouped_cell_contents(line_groups) do
    line_groups
    |> Enum.map(fn line_group ->
      line_group
      |> Enum.map(fn line ->
        [_all, trimmed_line] = Regex.run(~r/^\s*\|\s*(.*)\s*\|\s*$/, line)

        trimmed_line
        |> String.split("|")
        |> Enum.map(fn cell_content ->
          String.trim(cell_content)
        end)
      end)
    end)
  end

  def folded_cell_contents(grouped_cell_contents) do
    grouped_cell_contents
    |> Enum.map(fn row_contents ->
      row_contents
      |> fold_contents_if_necessary
    end)
  end

  def fold_contents_if_necessary(row_contents) when length(row_contents) > 1 do
    Enum.zip(row_contents)
    |> Enum.map(fn foldables ->
      foldables
      |> Tuple.to_list()
      |> Enum.filter(fn text -> text != "" end)
      |> Enum.join(" ")
    end)
  end

  def fold_contents_if_necessary(row_contents) do
    hd(row_contents)
  end

  def specials(rows_of_columns) do
    rows_of_columns
    |> Enum.map(fn row ->
      row
      |> Enum.map(fn text ->
        special(text)
      end)
    end)
  end

  def special("true"), do: true
  def special("false"), do: false
  def special("nil"), do: nil
  def special(""), do: nil
  def special(":" <> rest), do: String.to_atom(rest)
  def special(not_special), do: not_special
end
