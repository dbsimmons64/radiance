defmodule Radiance.Schema do
  use Radiance.Config

  def create_preloads(fields) do
    # Return all fields that require a preload

    Enum.map(fields, fn field -> get_preload(field) end)
    |> Enum.filter(fn result -> result != nil end)
  end

  def get_preload(field) when is_atom(field) do
    nil
  end

  def get_preload(field) when is_map(field) do
    get_preload(field.name)
  end

  def get_preload(field) when is_list(field) do
    # Remove the last element of the list which represents field name
    [first | rest] = Enum.drop(field, -1)
    list_to_preload(first, rest)
  end

  @doc """
  Receive a field that relies on preloading a resource and return the correct argument to
  pass to a preload function.

  ## Examples


       [:pet, :name] => preload: [:pet]

       [:pet, :owner, :name] => preload: [pet: :owner]

       [:foo, :bar, :baz, :wibble, :field_name] => preload: [foo: [bar: :wibble]]

  """

  def list_to_preload(first, []) do
    [first]
  end

  def list_to_preload(key, value) do
    [first | rest] = value
    %{key => list_to_preload(first, rest)} |> Map.to_list()
  end

  def get_struct(module) do
    module.__struct__()
    # apply(module, :__struct__, [])
  end

  @doc """
  Returns the given changeset for the module

  If no changeset is given then a default of :changeset is assumed.


   Vet.Owners.Owner,
  nil,
  %Vet.Owners.Owner{
    __meta__: #Ecto.Schema.Metadata<:built, "owners">,
    id: nil,
    name: nil,
    pets: #Ecto.Association.NotLoaded<association :pets is not loaded>,
    inserted_at: nil,
    updated_at: nil
  },
  %{}
  """
  def get_changeset(module, changeset, schema, attrs) when changeset == nil do
    apply(module, :changeset, [schema, attrs])
  end

  def get_changeset(module, changeset, schema, attrs) do
    apply(module, changeset, [schema, attrs])
  end
end
