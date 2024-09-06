defmodule Radiance.Config do
  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    application_name = Application.get_env(:radiance, :application_name)
    repo = Application.get_env(:radiance, :repo, Radiance.Repo)
    auth = Application.get_env(:radiance, :auth, RadianceWeb.UserAuth)
    module_prefix = Application.get_env(:radiance, :module_prefix, "Radiance.Resource")
    url_prefix = Application.get_env(:radiance, :url_prefix, "/admin")

    quote do
      def repo() do
        unquote(repo)
      end

      def module_prefix() do
        unquote(module_prefix)
      end

      def url_prefix do
        unquote(url_prefix)
      end

      def application_name() do
        unquote(application_name)
      end

      def auth() do
        unquote(auth)
      end

      def menu() do
        # Enum.map(modules, fn module -> Module.split(module) end)
        {:ok, modules} = :application.get_key(unquote(application_name), :modules)
        modules
      end
    end
  end
end
