# Router

We have to start somewhere so lets start with the `router` and the set of standard routes that `radiance` provides.

```elixir
defmodule RadianceWeb.Router do
  use RadianceWeb, :router

  pipeline :admin do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {RadianceWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  defmacro fibril_admin(pipe) do
    import Phoenix.LiveView.Router, only: [live: 4]

    url_prefix = Application.get_env(:radiance, :url_prefix, "/admin")

    quote do
      scope unquote(url_prefix) do
        live_session :admin_user,
          on_mount: [{Radiance.Schema.auth(), :ensure_authenticated}] do
          pipe_through(unquote(pipe))
          live("/:resource", RadianceWeb.RadianceLive.Index, :index)
          live("/:resource/new", RadianceWeb.RadianceLive.Index, :new)
          live("/:resource/:id/edit", RadianceWeb.RadianceLive.Index, :edit)
        end
      end
    end
  end
end
```

The above defines three standard routes:
* Index - for listing a resource
* New - for creating a resource
* Edit - for updating a resource

TODO: Probably need a route for deleting a resource.

# URL Prefix
Radiance default to a path of `/admin` so to display a list of `Owners` you would use the url: `/admin/owners`. We can change the default path by setting `:url_prefix` in the `config.exs`.

```elixir
config :radiance,
  url_prefix: "/private"
```

Now to access an `Owner` resource you would use the url of `/private/owners`.

So next, lets pop over to the `RadianceWeb.RadianceLive.Index` to see what is going on there.

# RadianceWeb.RadianceLive.Index
We pass the resource name as part of the url e.g. `/admin/owners` to get a list of the `owners`.

```elixir
def mount(%{"resource" => resource}, _session, socket) do
    configuration = Module.concat([Schema.module_prefix(), String.capitalize(resource)])

    resource = configuration.resource
    table_opts = configuration.table

    columns = Table.get_columns_metadata(table_opts.columns, resource.module)

    preloads = Schema.create_preloads(table_opts.fields)

    {:ok,
     socket
     |> assign(:current_user, socket.assigns.current_user)
     |> assign(:configuration, configuration)
     |> assign(:table_opts, table_opts)
     |> assign(:url_prefix, Schema.url_prefix())
     |> assign(resource: resource)
     |> assign(:fields, columns)
     |> assign(:preloads, preloads)}
  end
```

The first thing we need to do is determine the module where the resource lives. In the case of the `owner` resource this would be something like `Vet.Resource.Owner`. The `Vet.Resource` comes from the `config.exs`.

```elixir
config :radiance,
  module_prefix: "Vet.Resource"
```

So we now know that we have a module `Vet.Resource.Owner` which is where you'll find the definition Radiance needs.

# Our first Resource Module
Lets take a look at a minimal resource module for the `owner`

```elixir
defmodule Fibril.Resource.Owners do

  def resource do
    %{schema: Vet.Owners.Owner, name: "owner"}
  end

  def table() do
    %{
      columns: [
        :name
      ]
    }
  end

end
```

The `resource` function provides meta information about a resource such as its name and where we can find the schema. The `table` function returns a map that defines how we will display a list for the specified resource. 

# Table Columns
A column can be defined as one of three types:
* atom
* list
* map

## Atom Column Type
The simplest column type is defined as an atom that represents the field in the schema, for example, `:name` or `:date_of_birth`. Radiance will use a set of sensible defaults to display the column. 

## The List Column Type
If you wish to display related data in a table then use a list. For example a `pet` will have an `owner`. In the schema this will be represented as a `belongs_to` relationship on the `pet` schema. When displaying the list of pets one of the columns may be the owners name. 

```elixir
[:owner, :name]
```

## The Map Column Type
A map provides the finest level of control for displaying a field. For example, you may wish to provide an `icon` and `description` for field.

```elixir
%{
    name: :date_of_birth,
    icon: "hero-calendar"
    iconColour: "text-red-500"
}
```

# Name key
The name key may itself be one of two types:
* atom
* list 

# Other entries in the map
When providing a map to describe a column the `value` of any `key` may be one of three types
* a simple value such as a a `string`, `atom` or `number`
* A map, where the keys represent the possible values of the column. For example `iconColour` could be represented as a map

```elixir
iconColour: %{
    "new" => "text-blue-500"
    "paid" => "text-green-500"
    "overdue" => "text-red-500"
}
```

The key will be taken from the value of the column.

* A function, see the section on functions below.

# Defining functions as values.
Radiance provide the capability to set a value based on the result of running a function. For example assuming we want to display a different colour text depending upon the value of the column. 

```elixir
textColour: [&calculate_colour/2, [:record]]

def calculate_colour(record) do
    if record.score > 50 do
        "bg-green-500"
    else
        "bg-orange-500"
    end
end
```

The second argument in the list is itself a list of values to be passed to the function. All argument  values are taken from `assigns`. There are a few special arguments
* :record - this is the current record being displayed in the row (or form)
* :form - the current values in the form, useful for cross field validation.
* :value - the value of the column

* :query - the query that will be run to populate the particular column or form field.

TODO: Need to review this list carefully to ensure it works in as many circumstances as possible.


# Preloads
Radiance is able to display columns from related tables. For example in the `pet` table you can specify the `owner` as a column.

```elixir

%{
  fields: [
    [:owner, :name]
  ]
}

```

In order to do this, Radiance will convert the above syntax to the syntax used by Ecto for a preload. So the above example becomes 

```elixir
preload: [:owner]
```

Radiance is able to cope with deeply nested relationships

```elixir
       [:foo, :bar, :baz, :wibble, :field_name] => preload: [foo: [bar: :wibble]]
```








