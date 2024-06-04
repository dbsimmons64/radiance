defmodule RadianceWeb.TableComponents do
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  attr(:column, :map, required: true)
  attr(:record, :map, required: true)

  def radiance_column(assigns) do
    # Set up the values for each of the settings in the column.

    assigns =
      assigns
      |> assign(:value, assigns.record[assigns.column.name])
      |> assign(:column_type, assigns.column.type)

    Enum.each(assigns.column, fn {k, v} ->
      get_value(k, v, assigns)
    end)

    ~H"""
    <.column assigns={assigns} />
    """
  end

  def get_value(key, value, assigns) when is_map(value) do
    column_value = assigns.record[assigns.column.name]

    %{key => value[column_value]}
  end

  def get_value(key, value, assigns) when is_list(value) do
    %{key => apply_function(value, assigns)}
  end

  def get_value(key, value, _assigns) do
    %{key => value}
  end

  def apply_function(list, assigns) do
    [func | args] = list

    args = Enum.map(args, fn arg -> assigns[arg] end)
    apply(func, args)
  end

  def column(%{column_type: :text} = assigns) do
    ~H"""
    <.description description={@column.description} >
      <.badge>
          <.icon icon={@column.icon} icon_colour={@column.icon_colour} icon_position={@column.icon_position}>
          <.prefix prefix={@column.prefix} />
          <span class={@text.classes}>
            <%= @value   %>
            </span>
            <.suffix suffix={@column.suffix} />
          </.icon>
        </.badge>
    </.description>
    """
  end

  attr(:badge, :boolean, required: false)
  attr(:badge_colour, :string, default: "bg-red-500")

  def badge(assigns) when is_nil(assigns.column.badge) do
    ~H"""
    <%= render_slot(@inner_block) %>
    """
  end

  def badge(assigns) do
    ~H"""
    <span class={["badge", @badge_colour]}>
      <%= render_slot(@inner_block) %>
    </span>
    """
  end

  attr(:description, :string, required: false)
  attr(:description_position, :atom, default: :below)

  def description(assigns) when is_nil(assigns.column.description) do
    ~H"""
    <%= render_slot(@inner_block) %>
    """
  end

  def description(assigns) do
    ~H"""
      <p
        :if={@description_position == :above}
        class={["text-sm", "text-gray-500", "dark:text-gray-400", "mb-1"]}
    >
          <%= @description.text %>
      </p>

      <%= render_slot(@inner_block) %>

      <p
        :if={@description_position == :below}
        class={@description.classes}>
          <%= @description.text %>
      </p>
    """
  end

  attr(:icon, :string, required: false)
  attr(:icon_position, :atom, default: :before)
  attr(:icon_colour, :string, default: "bg-red-500")

  def icon(assigns) when is_nil(assigns.column.icon) do
    ~H"""
    <%= render_slot(@inner_block) %>
    """
  end

  def icon(assigns) do
    ~H"""
      <span
        :if={@icon[:position] == :before}
        class={["ml-1", @icon, @icon_colour]}
      />

      <%= render_slot(@inner_block) %>

      <span
        :if={@icon[:position] == :after}
        class={["ml-1", @icon, @icon_colour]}
      />
    """
  end

  attr(:prefix, :atom, required: false)

  def prefix(assigns) when is_nil(assigns.column.prefix) do
    ~H"""
    <%= render_slot(@inner_block) %>
    """
  end

  def prefix(assigns) do
    ~H"""
    <span>
      <%= @prefix %>
    </span>
    """
  end

  attr(:suffix, :atom, required: false)

  def suffix(assigns) when is_nil(assigns.column.suffix) do
    ~H"""
    <%= render_slot(@inner_block) %>
    """
  end

  def suffix(assigns) do
    ~H"""
    <span>
      <%= @suffix %>
    </span>
    """
  end
end
