defmodule Tabular.TestSupportTest do
  use ExUnit.Case, async: true

  doctest Tabular

  describe "equal?" do
    test "when there is a false value in any cell, returns false" do
      results_table = [
        [true, true, true],
        [true, false, true],
        [true, true, true]
      ]

      refute Tabular.TestSupport.equal?(results_table)
    end

    test "when all cells are true, returns true" do
      results_table = [
        [true, true, true],
        [true, true, true],
        [true, true, true]
      ]

      assert Tabular.TestSupport.equal?(results_table)
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
            | Mike    | 11    |
            +---------+-------+
            | Zoe     | 20    |
            +---------+-------+
      """

      results_table = [
        [false, true],
        [true, false]
      ]

      comparators = %{"count" => &(abs(String.to_integer(&1) - String.to_integer(&2)) < 2)}

      assert Tabular.TestSupport.compare(table1, table2, comparators: comparators) ==
               results_table
    end
  end
end
