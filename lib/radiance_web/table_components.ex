defmodule RadianceWeb.TableComponents do
  use Phoenix.Component

  attr(:value, :string, required: true)
  attr(:limit, :integer, required: false)
  attr(:date_format, :string, required: false)
  attr(:words, :integer, required: false)

  def fb_sidebar(assigns) do
    module_prefix = Radiance.Schema.module_prefix() |> String.split(".")

    menu_items =
      Radiance.Schema.menu()
      |> Enum.map(fn module -> Module.split(module) end)
      |> Enum.filter(fn module -> List.starts_with?(module, module_prefix) end)
      |> Enum.map(fn module -> List.last(module) end)
      |> Enum.map(fn resource ->
        %{name: resource, url: Radiance.Schema.url_prefix() <> "/" <> resource}
      end)

    assigns = assign(assigns, :menu_items, menu_items)

    ~H"""
    <section class="fb-sidebar bg-gray-50 ">
        <div class="mt-6">
            <ul class="menu menu-md ">
            <%= for menu_item <- @menu_items do %>
            <div class={add_highlight(menu_item.name, @name)} >

                <li class="ml-4 mb-3">
                    <a href={menu_item.url}>
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
    <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 9.776c.112-.017.227-.026.344-.026h15.812c.117 0 .232.009.344.026m-16.5 0a2.25 2.25 0 0 0-1.883 2.542l.857 6a2.25 2.25 0 0 0 2.227 1.932H19.05a2.25 2.25 0 0 0 2.227-1.932l.857-6a2.25 2.25 0 0 0-1.883-2.542m-16.5 0V6A2.25 2.25 0 0 1 6 3.75h3.879a1.5 1.5 0 0 1 1.06.44l2.122 2.12a1.5 1.5 0 0 0 1.06.44H18A2.25 2.25 0 0 1 20.25 9v.776" />
    </svg>

                        <%= menu_item.name %>

                    </a>
                </li>
                </div>
              <% end %>
            </ul>
        </div>
    </section>
    """
  end

  def add_highlight(menu_name, name) do
    if menu_name == String.capitalize(name) do
      "text-orange-500"
    else
      " "
    end
  end

  def fb_header(assigns) do
    ~H"""
    <header class="fb-header navbar border-b-2 border-gray-200">

    <div class="flex-1">
      <a class="btn btn-ghost text-xl">Laravel</a>
    </div>
    <div class="flex-none">
      <ul class="menu menu-horizontal px-1">
          <li><a>Link</a></li>
          <li>
              <details>
                  <summary>
                      Parent
                  </summary>
                  <ul class="p-2 bg-base-100 rounded-t-none">
                      <li><a>Link 1</a></li>
                      <li><a>Link 2</a></li>
                  </ul>
              </details>
          </li>
      </ul>
    </div>
    </header>
    """
  end
end
