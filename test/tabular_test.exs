defmodule TabularTest do
  use ExUnit.Case, async: true

  doctest Tabular

  describe "has_separators?" do
    test "true when the table has separators" do
      data_as_table = """
            +-----------+--------------------+--------------+
            | name      | dob                | predictable? |
            +-----------+--------------------+--------------+
            | Malcolm   | September 20, 2468 | false        |
            +-----------+--------------------+--------------+
            | Zoe       | February 15, 2484  |              |
            +-----------+--------------------+--------------+
      """

      assert Tabular.has_separators?(data_as_table)
    end

    test "false when the table does not have separators" do
      data_as_table = """
      +-----------+--------------------+--------------+
      | name      | dob                | predictable? |
      +-----------+--------------------+--------------+
      | Malcolm   | September 20, 2468 | false        |
      | Zoe       | February 15, 2484  |              |
      +-----------+--------------------+--------------+
      """

      refute Tabular.has_separators?(data_as_table)
    end
  end

  describe "cell_line_groups" do
    test "when separator lines, extracts lines with cell contents and groups them" do
      data_as_lines = [
        "+-----------+--------------------+",
        "| name      | dob                |",
        "+-----------+--------------------+",
        "| Malcolm   | September 20, 2468 |",
        "| Reynolds  |                    |",
        "+-----------+--------------------+",
        "| Jane      |                    |",
        "+-----------+--------------------+"
      ]

      expected = [
        ["| name      | dob                |"],
        ["| Malcolm   | September 20, 2468 |", "| Reynolds  |                    |"],
        ["| Jane      |                    |"]
      ]

      assert Tabular.cell_line_groups(data_as_lines, has_separators?: true) == expected
    end

    test "without separator lines, extracts lines with cell contents and groups them" do
      data_as_lines = [
        "+-----------+--------------------+",
        "| name      | dob                |",
        "+-----------+--------------------+",
        "| Malcolm   | September 20, 2468 |",
        "| Jane      |                    |",
        "+-----------+--------------------+"
      ]

      expected = [
        ["| name      | dob                |"],
        ["| Malcolm   | September 20, 2468 |"],
        ["| Jane      |                    |"]
      ]

      assert Tabular.cell_line_groups(data_as_lines, has_separators?: false) == expected
    end
  end

  describe "folded_cell_contents" do
    test "returns folded strings" do
      data = [
        [["name", "dob"]],
        [["Malcolm", "September 20, 2468"], ["Reynolds", ""]],
        [["Jane", ""]]
      ]

      expected = [
        ["name", "dob"],
        ["Malcolm Reynolds", "September 20, 2468"],
        ["Jane", ""]
      ]

      assert Tabular.folded_cell_contents(data) == expected
    end
  end

  describe "lines" do
    test "splits and trims lines" do
      data_as_table = """
      line 1
      line 2
      line 3
      """

      expected = [
        "line 1",
        "line 2",
        "line 3"
      ]

      assert Tabular.lines(data_as_table) == expected
    end
  end

  describe "to_list_of_lists" do
    test "returns values as a list of lists" do
      data_as_table = """
            +-----------+--------------------+--------------+
            | name      | dob                | predictable? |
            +-----------+--------------------+--------------+
            | Malcolm   | September 20, 2468 | false        |
            | Reynolds  |                    |              |
            +-----------+--------------------+--------------+
            | Zoe       | February 15, 2484  |              |
            | Washburne |                    |              |
            +-----------+--------------------+--------------+
            | Jane      | :unknown           | true         |
            +-----------+--------------------+--------------+
            | Derrial   | nil                | true         |
            | Book      |                    |              |
            +-----------+--------------------+--------------+
      """

      actual = Tabular.to_list_of_lists(data_as_table)

      expected = [
        ["name", "dob", "predictable?"],
        ["Malcolm Reynolds", "September 20, 2468", false],
        ["Zoe Washburne", "February 15, 2484", ""],
        ["Jane", :unknown, true],
        ["Derrial Book", nil, true]
      ]

      assert actual == expected
    end

    test "returns values as a list of lists from tables without separator lines" do
      data_as_table = """
            +-----------+--------------------+--------------+
            | name      | dob                | predictable? |
            +-----------+--------------------+--------------+
            | Malcolm   | September 20, 2468 | false        |
            | Zoe       | February 15, 2484  |              |
            | Jane      | :unknown           | true         |
            | Derrial   | nil                | true         |
            +-----------+--------------------+--------------+
      """

      actual = Tabular.to_list_of_lists(data_as_table)

      expected = [
        ["name", "dob", "predictable?"],
        ["Malcolm", "September 20, 2468", false],
        ["Zoe", "February 15, 2484", ""],
        ["Jane", :unknown, true],
        ["Derrial", nil, true]
      ]

      assert actual == expected
    end

    test "with header: false, returns values as a list of lists without the header" do
      data_as_table = """
            +-----------+--------------------+--------------+
            | name      | dob                | predictable? |
            +-----------+--------------------+--------------+
            | Malcolm   | September 20, 2468 | false        |
            | Reynolds  |                    |              |
            +-----------+--------------------+--------------+
            | Zoe       | February 15, 2484  |              |
            | Washburne |                    |              |
            +-----------+--------------------+--------------+
            | Jane      | :unknown           | true         |
            +-----------+--------------------+--------------+
            | Derrial   | nil                | true         |
            | Book      |                    |              |
            +-----------+--------------------+--------------+
      """

      actual = Tabular.to_list_of_lists(data_as_table, header: false)

      expected = [
        ["Malcolm Reynolds", "September 20, 2468", false],
        ["Zoe Washburne", "February 15, 2484", ""],
        ["Jane", :unknown, true],
        ["Derrial Book", nil, true]
      ]

      assert actual == expected
    end
  end

  describe "to_list_of_maps" do
    test "returns values as a list of maps" do
      data_as_table = """
            +-----------+--------------------+--------------+
            | name      | dob                | predictable? |
            +-----------+--------------------+--------------+
            | Malcolm   | September 20, 2468 | false        |
            | Reynolds  |                    |              |
            +-----------+--------------------+--------------+
            | Zoe       | February 15, 2484  |              |
            | Washburne |                    |              |
            +-----------+--------------------+--------------+
            | Jane      | :unknown           | true         |
            +-----------+--------------------+--------------+
            | Derrial   | nil                | true         |
            | Book      |                    |              |
            +-----------+--------------------+--------------+
      """

      actual = Tabular.to_list_of_maps(data_as_table)

      expected = [
        %{name: "Malcolm Reynolds", dob: "September 20, 2468", predictable?: false},
        %{name: "Zoe Washburne", dob: "February 15, 2484", predictable?: ""},
        %{name: "Jane", dob: :unknown, predictable?: true},
        %{name: "Derrial Book", dob: nil, predictable?: true}
      ]

      assert actual == expected
    end
  end

  describe "trimmed_and_grouped_cell_contents" do
    test "returns cleaned strings" do
      data_as_line_groups = [
        ["| name      | dob                |"],
        ["| Malcolm   | September 20, 2468 |", "| Reynolds  |                    |"],
        ["| Jane      |                    |"]
      ]

      expected = [
        [["name", "dob"]],
        [["Malcolm", "September 20, 2468"], ["Reynolds", ""]],
        [["Jane", ""]]
      ]

      assert Tabular.trimmed_and_grouped_cell_contents(data_as_line_groups) == expected
    end
  end
end
