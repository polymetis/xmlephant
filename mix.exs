defmodule Xmlephant.MixProject do
  use Mix.Project

  @source_url "https://github.com/polymetis/xmlephant"
  @version "0.1.0"

  def project do
    [
      app: :xmlephant,
      version: @version,
      elixir: "~> 1.15",
      name: "Xmlephant",
      package: package(),
      docs: docs(),
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:postgrex, "~> 0.22"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:ecto, "~> 3.10", only: [:dev, :test]},
      {:ecto_sql, "~> 3.13", only: [:dev, :test]},
      {:stream_data, "~> 1.0", only: [:dev, :test]}
    ]
  end

  defp package do
    [
      description: "A Postgrex extension for the PostgreSQL xml column type.",
      files: ["lib", "mix.exs", ".formatter.exs", "README.md", "CHANGELOG.md", "LICENSE"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      extras: ["CHANGELOG.md", "README.md", "LICENSE"],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"]
    ]
  end
end
