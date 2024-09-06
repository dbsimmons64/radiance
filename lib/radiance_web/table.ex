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
      column_type: get_metadata(:type, column, schema) |> get_display_type(),
      label: set_label(column),
      column_value: nil
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

  @doc """
  Generate a label for the given field.

  The label itself can be based on:
    1. A simple atom e.g. :name, :date_of_birth
    2. A list [:owner, :name] generally used for associations
    3 A msp with a `label` key
    4. A map with a key of name: the value of which is an atom
    5. A map with a key of name: the value of which is a list

    A label based on a field name has the first letter capitalised and underscores replaced with
    spaces e..g `:date_of_birth` becomes `Date of birth`
  """
  def set_label(field) when is_atom(field) do
    create_label(field)
  end

  def set_label(field) when is_map(field) do
    field[:label] || set_label(field.name)
  end

  def set_label(field) when is_list(field) do
    set_label(List.last(field))
  end

  def create_label(name) do
    name
    |> Atom.to_string()
    |> String.capitalize()
    |> String.replace("_", " ")
  end
end
