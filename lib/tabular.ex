defmodule Tabular do
  @moduledoc """
  Tabular converts an ascii table string into either a list of lists or a list of maps.
  """

  @row_splitter_re ~r/^\s*[|+]--[-+|]+$/

  @doc ~S'''

  Converts an ascii table to a list of maps.

  ## Examples

      iex> ascii_table = """
      ...> |---------------+--------------------|
      ...> | name          | dob                |
      ...> |---------------+--------------------|
      ...> | Malcolm       | September 20, 2468 |
      ...> | Reynolds      |                    |
      ...> |---------------+--------------------|
      ...> | Zoe Washburne | February 15, 2484  |
      ...> |---------------+--------------------|
      ...> """
      ...> Tabular.to_list_of_maps(ascii_table)
      [
        %{dob: "September 20, 2468", name: "Malcolm Reynolds"},
        %{dob: "February 15, 2484", name: "Zoe Washburne"}
      ]

      Without separators:

      iex> ascii_table = """
      ...> |------------------+--------------------|
      ...> | name             | dob                |
      ...> |------------------+--------------------|
      ...> | Malcolm Reynolds | September 20, 2468 |
      ...> | Zoe Washburne    | February 15, 2484  |
      ...> |------------------+--------------------|
      ...> """
      ...> Tabular.to_list_of_maps(ascii_table)
      [
        %{dob: "September 20, 2468", name: "Malcolm Reynolds"},
        %{dob: "February 15, 2484", name: "Zoe Washburne"}
      ]

  '''
  def to_list_of_maps(ascii_table) do
    [headers | rows] = to_list_of_lists(ascii_table)
    headers_as_atoms = Enum.map(headers, &String.to_atom(&1))

    rows
    |> Enum.map(fn row ->
      Enum.zip(headers_as_atoms, row)
      |> Map.new()
    end)
  end

  @doc deprecated: "Use to_list_of_lists(table, header: false) instead"
  @doc ~S'''

  Converts an ascii table to a list of lists, omitting the header row.

  ## Examples

      iex> ascii_table = """
      ...> |---------------+--------------------|
      ...> | name          | dob                |
      ...> |---------------+--------------------|
      ...> | Malcolm       | September 20, 2468 |
      ...> | Reynolds      |                    |
      ...> |---------------+--------------------|
      ...> | Zoe Washburne | February 15, 2484  |
      ...> |---------------+--------------------|
      ...> """
      ...> Tabular.to_list_of_lists_no_header(ascii_table)
      [
        ["Malcolm Reynolds", "September 20, 2468"],
        ["Zoe Washburne", "February 15, 2484"]
      ]

      Without separators:

      iex> ascii_table = """
      ...> |------------------+--------------------|
      ...> | name             | dob                |
      ...> |------------------+--------------------|
      ...> | Malcolm Reynolds | September 20, 2468 |
      ...> | Zoe Washburne    | February 15, 2484  |
      ...> |------------------+--------------------|
      ...> """
      ...> Tabular.to_list_of_lists_no_header(ascii_table)
      [
        ["Malcolm Reynolds", "September 20, 2468"],
        ["Zoe Washburne", "February 15, 2484"]
      ]

  '''
  def to_list_of_lists_no_header(ascii_table) do
    to_list_of_lists(ascii_table, header: false)
  end

  @doc ~S'''

  Converts an ascii table to a list of lists.

  ## Examples

      iex> ascii_table = """
      ...> |---------------+--------------------|
      ...> | name          | dob                |
      ...> |---------------+--------------------|
      ...> | Malcolm       | September 20, 2468 |
      ...> | Reynolds      |                    |
      ...> |---------------+--------------------|
      ...> | Zoe Washburne | February 15, 2484  |
      ...> |---------------+--------------------|
      ...> """
      ...> Tabular.to_list_of_lists(ascii_table)
      [
        ["name", "dob"],
        ["Malcolm Reynolds", "September 20, 2468"],
        ["Zoe Washburne", "February 15, 2484"]
      ]
      ...> Tabular.to_list_of_lists(ascii_table, header: false)
      [
        ["Malcolm Reynolds", "September 20, 2468"],
        ["Zoe Washburne", "February 15, 2484"]
      ]

      Without separators:

      iex> ascii_table = """
      ...> |------------------+--------------------|
      ...> | name             | dob                |
      ...> |------------------+--------------------|
      ...> | Malcolm Reynolds | September 20, 2468 |
      ...> | Zoe Washburne    | February 15, 2484  |
      ...> |------------------+--------------------|
      ...> """
      ...> Tabular.to_list_of_lists(ascii_table)
      [
        ["name", "dob"],
        ["Malcolm Reynolds", "September 20, 2468"],
        ["Zoe Washburne", "February 15, 2484"]
      ]
      ...> Tabular.to_list_of_lists(ascii_table, header: false)
      [
        ["Malcolm Reynolds", "September 20, 2468"],
        ["Zoe Washburne", "February 15, 2484"]
      ]
  '''
  def to_list_of_lists(ascii_table, opts \\ [header: true]) do
    rows =
      ascii_table
      |> lines()
      |> cell_line_groups(has_separators?: has_separators?(ascii_table))
      |> trimmed_and_grouped_cell_contents()
      |> folded_cell_contents()
      |> specials()

    if opts[:header], do: rows, else: Enum.drop(rows, 1)
  end

  @doc false
  def lines(ascii_table) do
    ascii_table
    |> String.trim()
    |> String.split("\n")
  end

  @doc false
  def cell_line_groups(lines, has_separators?: true) do
    lines
    |> Enum.chunk_by(fn line ->
      Regex.match?(@row_splitter_re, line)
    end)
    |> Enum.filter(fn group ->
      !(length(group) == 1 &&
          Regex.match?(@row_splitter_re, hd(group)))
    end)
  end

  @doc false
  def cell_line_groups(lines, has_separators?: false) do
    lines
    |> Enum.reject(&(&1 =~ @row_splitter_re))
    |> Enum.map(&[&1])
  end

  @doc false
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

  @doc false
  def folded_cell_contents(grouped_cell_contents) do
    grouped_cell_contents
    |> Enum.map(fn row_contents ->
      row_contents
      |> fold_contents_if_necessary
    end)
  end

  @doc false
  def fold_contents_if_necessary(row_contents) when length(row_contents) > 1 do
    Enum.zip(row_contents)
    |> Enum.map(fn foldables ->
      foldables
      |> Tuple.to_list()
      |> Enum.filter(fn text -> text != "" end)
      |> Enum.join(" ")
    end)
  end

  @doc false
  def fold_contents_if_necessary(row_contents) do
    hd(row_contents)
  end

  @doc false
  def specials(rows_of_columns) do
    rows_of_columns
    |> Enum.map(fn row ->
      row
      |> Enum.map(fn text ->
        special(text)
      end)
    end)
  end

  @doc false
  def special("true"), do: true
  def special("false"), do: false
  def special("nil"), do: nil
  def special(""), do: ""
  def special(":" <> rest), do: String.to_atom(rest)
  def special(not_special), do: not_special

  @doc false
  def has_separators?(ascii_table) do
    [_, _, _ | lines] = lines(ascii_table)
    {_, lines} = List.pop_at(lines, -1)

    Enum.any?(lines, &(&1 =~ @row_splitter_re))
  end
end
