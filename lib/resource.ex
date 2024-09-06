defmodule Radiance.Resource do
  alias Radiance.Schema
  require Ecto.Query

  def list_records(struct, _preloads = nil, params) do
    # struct
    # |> Schema.repo().all()

    struct
    |> Flop.validate_and_run(params, repo: Schema.repo())
  end

  def list_records(struct, preloads, params) do
    # struct |> Ecto.Query.preload(^preloads) |> Schema.repo().all()
    struct
    |> Ecto.Query.preload(^preloads)
    |> Flop.validate_and_run(params, repo: Schema.repo())
  end

  @doc """
  Get the value of the given field from the provided record.

  The field itself can be based on:
    1. A simple atom e.g. :name, :date_of_birth
    2. A list [:owner, :name] generally used for associations
    3  A map with a key of name: the value of which is an atom
    4. A map with a key of name: the value of which is a list
  """
  def fetch_data(record, field) when is_list(field) do
    keys = Enum.map(field, fn f -> Access.key(f, %{}) end)
    get_in(record, keys)
  end

  def fetch_data(record, field) when is_map(field) do
    fetch_data(record, field.name)
  end

  def fetch_data(record, field) do
    Map.get(record, field)
  end

  def get_changeset(configuration, params) do
    resource = apply(configuration, :resource, [])
    table = apply(configuration, :table, [])

    Schema.get_changeset(
      resource.module,
      table[:changeset],
      Schema.get_struct(resource.module),
      params
    )
  end

  def get_changeset(configuration, record, params) do
    resource = apply(configuration, :resource, [])
    table = apply(configuration, :table, [])

    Schema.get_changeset(
      resource.module,
      table[:changeset],
      record,
      params
    )
  end
end
