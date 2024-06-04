defmodule RadianceWeb.Table do
  def get_columns_metadata(columns, schema) do
    # Return the default column_type for the field

    Enum.map(columns, fn column -> get_column_metadata(column, schema) end)
  end

  @doc """
  Returns a map containing the ecto and display type for the specified column merged
  with any possible settings defined as a map.
  """
  def get_column_metadata(column, schema) when is_map(column) do
    get_column_metadata(column.name, schema)
    |> Map.merge(column, fn _k, _v1, v2 -> v2 end)
  end

  def get_column_metadata(column, schema) when is_atom(column) or is_list(column) do
    # We don't have a map of settings for this column so return a new map with minimal data
    # in it.
    %{
      name: column,
      ecto_type: get_metadata(:type, column, schema),
      display_type: get_metadata(:type, column, schema) |> get_display_type()
    }
  end

  def get_metadata(type, field, schema) do
    schema.__schema__(type, field)
  end

  def get_display_type(:integer) do
    :integer
  end

  def get_display_type(:date) do
    :date
  end

  def get_display_type(:decimal) do
    :decimal
  end

  def get_display_type(_ecto_type) do
    :text
  end
end
