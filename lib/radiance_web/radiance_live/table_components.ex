defmodule RadianceWeb.RadianceLive.TableComponents do
  use Phoenix.Component
  alias Radiance.Resource

  attr(:column, :map, required: true)
  attr(:record, :map, required: true)

  def column(assigns) do
    # TODO: Rename Resource.fetch_data() to something more appropriate get_field_value

    # Get the value of field in the record
    record_value = Resource.fetch_data(assigns.record, assigns.column.name)
    column_value = set_column_value(assigns.column.column_value, record_value, assigns)

    assigns =
      assigns
      |> assign(:record_value, record_value)
      |> assign(:column_value, column_value)

    # Determine the value for each column setting
    assigns = assign(assigns, :column, set_column_settings(assigns))

    # Create the column component
    column(assigns.column.column_type, assigns)
  end

  @doc """
  Set the value of the column

  The value can be nil, a simple value, a map or a function.
  """
  def set_column_value(column_value, record_value, _assigns) when is_nil(column_value) do
    # column_value key not set so simply use the record value
    record_value
  end

  def set_column_value(column_value, record_value, _assigns) when is_map(column_value) do
    column_value[record_value]
  end

  def set_column_value(column_value, _record_value, assigns) when is_list(column_value) do
    apply_function(column_value, assigns)
  end

  def set_column_value(column_value, _record_value, _assigns) do
    # column_value is set to a simple value e.g. string, number so use this
    column_value
  end

  def set_column_settings(assigns) do
    Enum.reduce(assigns.column, %{}, fn {key, value}, acc ->
      Map.put(acc, key, get_value(value, assigns))
    end)
  end

  @doc """
  Returns the value for the given column parameter.

  A column parameter consists of the parameter name, for example `icon` followed by one of three possible types of value:

  * a simple value such as a string or number, for example,

  ```
  icon: "hero-envelope",

  ```

  * A map with the value of the column being the key and returing the maps value,

  ```
  icon: %{
  "dog" => "hero-dog-icon",
  "cat" => "hero-cat-icon"
  }

  ```

  * A function,

  ```
  icon: [&myfunction/1, :record]
  ```
  """

  def get_value(value, assigns) when is_map(value) do
    # dbg("Get Value called")
    # dbg(value)
    # dbg(assigns)
    # column_value = assigns.record[assigns.column.name]
    # dbg(column_value)

    value[assigns.column_value]
  end

  def get_value(value, assigns) when is_list(value) do
    apply_function(value, assigns)
  end

  def get_value(value, _assigns) do
    value
  end

  def apply_function(list, assigns) do
    [func | args] = list

    args =
      Enum.map(args, fn arg ->
        assigns[arg]
      end)

    apply(func, args)
  end

  def column(:text, assigns) do
    ~H"""
    <.description description={@column[:description]} description_position={@column[:description_position]}>
      <.badge badge={@column[:badge]} badge_colour={@column[:badge_colour]}>
          <.text_icon icon={@column[:icon]} icon_colour={@column[:icon_colour]} icon_position={@column[:icon_position]}>
          <.prefix prefix={@column[:prefix]} />
            <.text value={@column_value} limit={@column[:limit]} words={@column[:words]} date_format={@column[:date_format]}/>
            <.suffix suffix={@column[:suffix]} />
          </.text_icon>
        </.badge>
    </.description>
    """
  end

  def column(:icon, assigns) do
    icon = assigns.column[:icon] || get_boolean_icon(assigns)

    icon_colour =
      assigns.column[:icon_colour] || get_boolean_icon_colour(assigns) || "text-red-500"

    assigns =
      assigns
      |> assign(:icon, icon)
      |> assign(:icon_colour, icon_colour)

    ~H"""
    <.description description={@column[:description]} description_position={@column[:description_position]}>
      <.icon icon={@icon} icon_colour={@icon_colour}/>
    </.description>
    """
  end

  def column(column_type, assigns) do
    # the column type is a module, call the module's rad_column function
    column_type.rad_column(assigns)
  end

  def text(assigns) do
    value =
      assigns.value
      |> limit(assigns.limit)
      |> words(assigns.words)
      |> format_date(assigns.date_format)

    assigns = assign(assigns, :value, value)

    ~H"""
      <span >
        <%= @value   %>
      </span>
    """
  end

  attr(:prefix, :atom, required: false)
  slot(:inner_block)

  def prefix(assigns) when is_nil(assigns.prefix) do
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
  slot(:inner_block)

  def suffix(assigns) when is_nil(assigns.suffix) do
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

  def icon(assigns) do
    ~H"""
      <span
        class={["ml-1", @icon, @icon_colour]}
      />
    """
  end

  attr(:badge, :boolean, required: false)
  attr(:badge_colour, :string, default: "bg-red-500")
  slot(:inner_block)

  def badge(assigns) when is_nil(assigns.badge) do
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
  slot(:inner_block)

  def description(assigns) when is_nil(assigns.description) do
    ~H"""
    <%= render_slot(@inner_block) %>
    """
  end

  def description(assigns) do
    assigns =
      assigns
      |> assign(:description_position, assigns.description_position || :below)

    ~H"""
      <p
        :if={@description_position == :above}
        class={["text-sm", "text-gray-500", "dark:text-gray-400", "mb-1"]}
    >
          <%= @description %>
      </p>

      <%= render_slot(@inner_block) %>

      <p
        :if={@description_position == :below}
        class={["text-sm", "text-gray-500", "dark:text-gray-400", "mb-1"]}
      >
          <%= @description %>
      </p>
    """
  end

  attr(:icon, :string, required: false)
  attr(:icon_position, :atom, default: :before)
  attr(:icon_colour, :string, default: "bg-red-500")
  slot(:inner_block)

  def text_icon(assigns) when is_nil(assigns.icon) do
    ~H"""
    <%= render_slot(@inner_block) %>
    """
  end

  def text_icon(assigns) do
    assigns =
      assigns
      |> assign(:icon_position, assigns.icon_position || :before)

    ~H"""
      <span
        :if={@icon_position == :before}
        class={["ml-1", @icon, @icon_colour]}
      />

      <%= render_slot(@inner_block) %>

      <span
        :if={@icon_position == :after}
        class={["ml-1", @icon, @icon_colour]}
      />
    """
  end

  def limit(value, limit) when is_nil(limit) do
    value
  end

  def limit(value, limit) do
    String.slice(value, 0, limit) <> "..."
  end

  def words(value, words) when is_nil(words) do
    value
  end

  def words(value, words) do
    value = String.split(value) |> Enum.take(words) |> Enum.join(" ")
    value <> "..."
  end

  def format_date(value, date_format) when is_nil(date_format) do
    value
  end

  def format_date(value, date_format) do
    case Timex.format(value, date_format, :strftime) do
      {:ok, value} -> value
      {:error, _} -> "Invalid Date"
    end
  end

  def get_boolean_icon(%{boolean: boolean}) when is_nil(boolean) do
    nil
  end

  def get_boolean_icon(assigns) do
    if assigns.column_value do
      assigns.column[:true_icon] || "hero-check-circle"
    else
      assigns.column[:false_icon] || "hero-x-circle"
    end
  end

  def get_boolean_icon_colour(%{boolean: boolean}) when is_nil(boolean) do
    nil
  end

  def get_boolean_icon_colour(assigns) do
    if assigns.column_value do
      assigns.column[:true_icon_colour]
    else
      assigns.column[:false_icon_colour]
    end
  end
end
