defmodule Xmlephant.MixProject do
  use Mix.Project

  @sourceurl "https://github.com/polymetis/xmlephant"
  @version "0.0.1"

  def project do
    [
      app: :xmlephant,
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
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
      {:postgrex, ">= 0.0.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:ecto_sql, "~> 3.0", optional: true, only: :test}
    ]
  end

  defp package do
    [
      description: "Xmlephant allows you to work directly with xml directly in Postgres",
      files: ["lib", "mix.exs", "README.md", "CHANGELOG.md"],
      maintainers: ["Moisis Langley ('Ley) Missailidis"],
      licenses: ["MIT"],
      links: %{"GitHub" => @sourceurl}
    ]
  end

  defp docs do
    [
      extras: ["CHANGELOG.md", "README.md"],
      main: "readme",
      source_url: @sourceurl,
      source_ref: "v#{@version}",
      formatters: ["html"]
    ]
  end
end
