defmodule Radiance.MixProject do
  use Mix.Project

  def project do
    [
      app: :radiance,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:phoenix_view, "~> 2.0"},
      {:ecto_sql, "~> 3.10"},
      {:phoenix_live_view, "~> 0.20.2"},
      {:gettext, "~> 0.20"},
      {:postgrex, ">= 0.0.0"},
      {:jason, "~> 1.2"},
      {:floki, ">= 0.30.0", only: :test},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:flop, "~> 0.25.0"},
      {:flop_phoenix, "~> 0.22.8"},
      {:timex, "~> 3.0"},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1}
    ]
  end
end
