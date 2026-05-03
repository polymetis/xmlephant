defmodule Xmlephant.Test.Helper do
  def opts(types \\ Xmlephant.PostgrexTypes) do
    [
      hostname: System.get_env("PG_HOSTNAME", "localhost"),
      username: System.get_env("PG_USERNAME", "postgres"),
      password: System.get_env("PG_PASSWORD", "postgres"),
      database: System.get_env("PG_DATABASE", "xmlephant_test"),
      types: types
    ]
  end
end

ExUnit.start()

# Skip booting the Ecto.Repo when the :ecto tag is excluded so isolated
# runs of non-Ecto suites (e.g. `mix test --exclude ecto`) don't pay the
# connection cost or require a live database.
unless :ecto in (ExUnit.configuration()[:exclude] || []) do
  {:ok, _} = Application.ensure_all_started(:ecto_sql)
  {:ok, _} = Xmlephant.Test.Repo.start_link()
  Ecto.Adapters.SQL.Sandbox.mode(Xmlephant.Test.Repo, :manual)
end
