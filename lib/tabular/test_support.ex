defmodule Tabular.TestSupport do
  @moduledoc """
  Functions to simplify testing with ascii tables.
  """

  @doc ~S'''

  Compares two ascii tables, producing a matrix of the individual comparisons.

  An optional map of comparator functions can be used. Comparators are useful when values
  in the tables cannot be compared by simple equality, such as floating point values that
  may be consider equal when the 2 values are close.

  Each cell
  in the matrix is either a single value or a tuple of values.

  - A single value indicates that both tables have the same value at that position. The
    value is the actual value found in both tables at that position or the value from the
    first table when using a comparator function

  - A tuple indicates that the two tables have different values at that position. The
    tuple contains the differing values from the two tables.

  Comparators are functions that take 2 values as arguments and return true when the
  values are to be considered a match and false otherwise.

  The keys in the comparator map indicate the table column where the comparator is to be
  used.

  ## Example

      iex> table1 = """
      ...>   +---------+-------+
      ...>   | name    | count |
      ...>   +---------+-------+
      ...>   | Malcolm | 10    |
      ...>   +---------+-------+
      ...>   | Zoe     | 5     |
      ...>   +---------+-------+
      ...> """
      ...>
      ...> table2 = """
      ...>   +---------+-------+
      ...>   | name    | count |
      ...>   +---------+-------+
      ...>   | Mike    | 11    |
      ...>   +---------+-------+
      ...>   | Zoe     | 20    |
      ...>   +---------+-------+
      ...> """
      ...>
      ...> comparators = %{"count" => &(abs(String.to_integer(&1) - String.to_integer(&2)) < 2)}
      ...>
      ...> Tabular.TestSupport.compare(table1, table2, comparators: comparators)
      [
        ["name", "count"],
        [{"Malcolm", "Mike"}, "10"],
        ["Zoe", {"5", "20"}]
      ]
  '''

  def compare(actual_table, expected_table, opts \\ [comparators: %{}]) do
    actual_table_data = actual_table |> Tabular.to_list_of_lists()
    expected_table_data = expected_table |> Tabular.to_list_of_lists()

    [actual_headers | actual_table_rows] = actual_table_data
    [expected_header_row | expected_table_rows] = expected_table_data

    [actual_headers] ++
      (Enum.zip(actual_table_rows, expected_table_rows)
       |> Enum.map(fn {actual_row, expected_row} ->
         Enum.zip([expected_header_row, actual_row, expected_row])
         |> Enum.map(fn {header, actual_value, expected_value} ->
           match? =
             case opts[:comparators][header] do
               nil -> actual_value == expected_value
               comparator -> comparator.(actual_value, expected_value)
             end

           case match? do
             true -> actual_value
             false -> {actual_value, expected_value}
           end
         end)
       end))
  end

  @doc ~S'''

  Examines the matrix produced by `compare`. Returns false
  if any cell is false. Otherwise returns true.

  ## Examples

      iex> results_table =
      ...> [
      ...>   ["name", "count"],
      ...>   [{"Malcolm", "Mike"}, "10"],
      ...>   ["Zoe", {"5", "20"}]
      ...> ]
      ...>
      ...> Tabular.TestSupport.equal?(results_table)
      false
  '''

  def equal?(compare_result) do
    Enum.all?(compare_result, fn row ->
      Enum.all?(row, fn
        {_, _} -> false
        _ -> true
      end)
    end)
  end

  @doc ~S'''

  Asserts that the contents of 2 tables are equal.
  If the tables are not equal, the failure message
  includes the table highlighting the differences
  in the cells that disagree.

  ## Examples

      iex> try do
      ...>   [
      ...>     ["name", "count"],
      ...>     [{"Malcolm", "Mike"}, "10"],
      ...>     ["Zoe", {"5", "20"}]
      ...>   ]
      ...>   |> Tabular.TestSupport.assert_equal()
      ...> rescue
      ...>   e in ExUnit.AssertionError ->
      ...>     e.message
      ...> end
      """
      +--------------------------+------------------+
      | name                     | count            |
      +--------------------------+------------------+
      | >>> Malcolm <=> Mike <<< | 10               |
      | Zoe                      | >>> 5 <=> 20 <<< |
      +--------------------------+------------------+
      """
  '''

  def assert_equal(results_table) do
    if equal?(results_table) do
      true
    else
      generate_error_message(results_table)
      |> ExUnit.Assertions.flunk()
    end
  end

  @doc false
  def generate_error_message([header | body]) do
    format_cells(body) |> TableRex.quick_render!(header)
  end

  @doc false
  def format_cells(results_table) do
    Enum.map(results_table, fn row ->
      Enum.map(row, fn
        {left, right} -> ">>> #{left} <=> #{right} <<<"
        cell -> cell
      end)
    end)
  end
end
