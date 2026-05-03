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

{:ok, _} = Application.ensure_all_started(:ecto_sql)
{:ok, _} = Xmlephant.Test.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(Xmlephant.Test.Repo, :manual)

ExUnit.start()
