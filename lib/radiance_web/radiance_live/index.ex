defmodule RadianceWeb.RadianceLive.Index do
  alias Ecto.Changeset
  use RadianceWeb, :live_view

  alias Radiance.Resource
  alias Radiance.Schema
  alias Radiance.Table

  @impl true
  def mount(%{"resource" => resource}, _session, socket) do
    configuration = Module.concat([Schema.module_prefix(), String.capitalize(resource)])

    resource = configuration.resource
    table_opts = configuration.table

    columns = Table.get_columns_metadata(table_opts.columns, resource.schema)
    preloads = Schema.create_preloads(table_opts.fields)

    {:ok,
     socket
     |> assign(:current_user, socket.assigns.current_user)
     |> assign(:configuration, configuration)
     |> assign(:table_opts, table_opts)
     |> assign(:url_prefix, Schema.url_prefix())
     |> assign(resource: resource)
     |> assign(:columns, columns)
     |> assign(:preloads, preloads)}
  end

  # @impl true

  # def handle_params(params, _url, socket) do
  #   {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  # end

  # defp apply_action(socket, :edit, %{"id" => id}) do
  #   resource = apply(socket.assigns.configuration, :resource, [])
  #   record = Schema.repo().get!(resource.module, id)

  #   socket
  #   |> assign(:page_title, "Edit #{String.capitalize(resource.name)}")
  #   |> assign(resource: resource)
  #   |> assign(:record, record)
  # end

  # defp apply_action(socket, :new, _params) do
  #   resource = apply(socket.assigns.configuration, :resource, [])

  #   socket
  #   |> assign(:page_title, "New #{String.capitalize(resource.name)}")
  #   |> assign(:record, Schema.get_struct(resource.module))
  # end

  # defp apply_action(socket, :index, params) do
  #   page_size = get_in(socket.assigns, [:table_opts, :pagination, :page_size])
  #   params = Map.merge(%{"page_size" => page_size}, params)

  #   resource = socket.assigns.configuration.resource

  #   {:ok, {records, meta}} =
  #     Resource.list_records(resource.module, socket.assigns.preloads, params)

  #   socket
  #   |> assign(:meta, meta)
  #   |> assign(:page_title, String.capitalize(socket.assigns.resource.plural))
  #   |> assign(:pet, nil)
  #   |> stream(:records, records, reset: true)
  # end

  # @impl true
  # def handle_info({RadianceWeb.RadianceLive.FormComponent, {:saved, _record}}, socket) do
  #   {:noreply, socket}
  # end

  # def handle_info({_sender, {:saved, record}}, socket) do
  #   {:noreply, stream_insert(socket, :records, record)}
  # end

  # @impl true
  # def handle_event("delete", %{"id" => id}, socket) do
  #   resource = apply(socket.assigns.configuration, :resource, [])
  #   record = Schema.repo().get!(resource.module, id)

  #   {:ok, _} = Schema.repo().delete(record)

  #   {:noreply, stream_delete(socket, :records, record)}
  # end

  # def handle_event("update", params, socket) do
  #   dbg(params)
  #   resource = apply(socket.assigns.configuration, :resource, [])
  #   record = Schema.repo().get!(resource.module, params["id"])

  #   params = %{params["name"] => params["content"]}

  #   case update_resource(socket, record, params) do
  #     {:ok, resource} ->
  #       send(self(), {__MODULE__, {:saved, resource}})
  #       {:noreply, socket}

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       errors =
  #         Changeset.traverse_errors(changeset, fn {msg, opts} ->
  #           Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
  #             opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
  #           end)
  #         end)

  #       {:reply, %{errors: errors}, socket}
  #   end
  # end

  # def update_resource(socket, record, attrs \\ %{}) do
  #   table = apply(socket.assigns.configuration, :table, [])
  #   preloads = Schema.create_preloads(table.fields)

  #   Resource.get_changeset(
  #     socket.assigns.configuration,
  #     record,
  #     attrs
  #   )
  #   |> Schema.repo().update()
  #   |> Radiance.Helpers.preload(preloads)
  # end
end
