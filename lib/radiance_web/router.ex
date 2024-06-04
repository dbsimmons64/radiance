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
