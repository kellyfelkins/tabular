defmodule Tabular.TestSupportTest do
  use ExUnit.Case, async: true

  doctest Tabular

  describe "assert_equal" do
    test "passes when tables are equal" do
      result_table = [
        ["name", "dob"],
        ["Malcolm", "September 20, 2468"],
        ["Zoe", "February 15, 2484"]
      ]

      assert Tabular.TestSupport.assert_equal(result_table)
    end

    test "flunks and prints table highlighting differences when tables are different" do
      expected_message = ~r|Malcolm <=> Mike|

      results_table = [
        ["name", "dob"],
        [{"Malcolm", "Mike"}, "September 20, 2468"],
        ["Zoe", "February 15, 2484"]
      ]

      assert_raise ExUnit.AssertionError, expected_message, fn ->
        Tabular.TestSupport.assert_equal(results_table)
      end
    end
  end

  describe "equal?" do
    test "when there is a non-matching value in any cell, returns false" do
      results_table = [
        ["name", "dob"],
        [{"Malcolm", "Mike"}, "September 20, 2468"],
        ["Zoe", "February 15, 2484"]
      ]

      refute Tabular.TestSupport.equal?(results_table)
    end

    test "when all cells match, returns true" do
      results_table = [
        ["name", "dob"],
        ["Mike", "September 20, 2468"],
        ["Zoe", "February 15, 2484"]
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
        ["name", "dob"],
        [{"Malcolm", "Mike"}, "September 20, 2468"],
        ["Zoe", "February 15, 2484"]
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
        ["name", "count"],
        [{"Malcolm", "Mike"}, "10"],
        ["Zoe", {"5", "20"}]
      ]

      comparators = %{"count" => &(abs(String.to_integer(&1) - String.to_integer(&2)) < 2)}

      assert Tabular.TestSupport.compare(table1, table2, comparators: comparators) ==
               results_table
    end
  end
end
