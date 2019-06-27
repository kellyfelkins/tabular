defmodule Tabular.TestSupportTest do
  use ExUnit.Case, async: true

  describe "equal?" do
    test "when there is a false value in any one of the rows, returns false" do
      results_table = [
        [true, true, true],
        [true, false, true],
        [true, true, true]
      ]

      refute Tabular.TestSupport.equal?(results_table)
    end

    test "is true when tables match" do
      table1 = """
            +---------+--------------------+
            | name    | dob                |
            +---------+--------------------+
            | Malcolm | September 20, 2468 |
            +---------+--------------------+
            | Zoe     | February 15, 2484  |
            +---------+--------------------+
      """

      table2 = table1

      assert Tabular.TestSupport.compare(table1, table2)
             |> Tabular.TestSupport.equal?()
    end

    test "is false when any cell does not match" do
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

      refute Tabular.TestSupport.compare(table1, table2)
             |> Tabular.TestSupport.equal?()
    end

    test "is true when all cell functions result in true" do
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
            | Zoe     | 4     |
            +---------+-------+
      """

      comparators = %{"count" => &near/2}

      assert Tabular.TestSupport.compare(table1, table2, comparators: comparators)
             |> Tabular.TestSupport.equal?()
    end

    test "is false when any cell function result in false" do
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
            | Malcolm | 31    |
            +---------+-------+
            | Zoe     | 4     |
            +---------+-------+
      """

      comparators = %{"count" => &near/2}

      refute Tabular.TestSupport.compare(table1, table2, comparators: comparators)
             |> Tabular.TestSupport.equal?()
    end
  end

  defp near(actual, expected) do
    actual_integer = String.to_integer(actual)
    expected_integer = String.to_integer(expected)
    abs(actual_integer - expected_integer) < 2
  end
end
