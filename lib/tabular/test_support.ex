defmodule Tabular.TestSupport do
  def compare(actual_table, expected_table, opts \\ [comparators: %{}]) do
    actual_table_data = actual_table |> Tabular.to_list_of_lists()
    expected_table_data = expected_table |> Tabular.to_list_of_lists()

    [_actual_headers | actual_table_rows] = actual_table_data
    [expected_header_row | expected_table_rows] = expected_table_data

    Enum.zip(actual_table_rows, expected_table_rows)
    |> Enum.map(fn {actual_row, expected_row} ->
      Enum.zip([expected_header_row, actual_row, expected_row])
      |> Enum.map(fn {header, actual_value, expected_value} ->
        case opts[:comparators][header] do
          nil -> actual_value == expected_value
          comparator -> comparator.(actual_value, expected_value)
        end
      end)
    end)
  end

  def equal?(compare_result) do
    Enum.all?(compare_result, fn row ->
      Enum.all?(row, & &1)
    end)
  end
end
