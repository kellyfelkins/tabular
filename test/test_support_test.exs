defmodule Tabular.TestSupportTest do
  use ExUnit.Case, async: true

  describe "equal?" do
    test "when there is a false value in any cell, returns false" do
      results_table = [
        [true, true, true],
        [true, false, true],
        [true, true, true]
      ]

      refute Tabular.TestSupport.equal?(results_table)
    end
  end

  describe "compare" do
    test "creates a matrix indicating non-matching cells with `false`" do
      table1 = """
            +---------+--------------------+
            | name    | dob                |
            +---------+--------------------+
            | Malcolm | September 20, 2468 |
            +---------+--------------------+
            | Zoe     | February 15, 2484  |
            +---------+--------------------+
      """

      table2 = """
            +---------+--------------------+
            | name    | dob                |
            +---------+--------------------+
            | Mike    | September 20, 2468 |
            +---------+--------------------+
            | Zoe     | February 15, 2484  |
            +---------+--------------------+
      """

      results_table = [
        [false, true],
        [true, true]
      ]

      assert Tabular.TestSupport.compare(table1, table2) == results_table
    end

    test "uses comparator functions to compare cells" do
      table1 = """
            +---------+-------+
            | name    | count |
            +---------+-------+
            | Malcolm | 10    |
            +---------+-------+
            | Zoe     | 5     |
            +---------+-------+
      """

      table2 = """
            +---------+-------+
            | name    | count |
            +---------+-------+
            | Malcolm | 11    |
            +---------+-------+
            | Zoe     | 20    |
            +---------+-------+
      """

      results_table = [
        [true, true],
        [true, false]
      ]

      comparators = %{"count" => &near/2}

      assert Tabular.TestSupport.compare(table1, table2, comparators: comparators) ==
               results_table
    end
  end

  defp near(actual, expected) do
    actual_integer = String.to_integer(actual)
    expected_integer = String.to_integer(expected)
    abs(actual_integer - expected_integer) < 2
  end
end
