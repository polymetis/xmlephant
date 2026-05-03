{:ok, _} = Application.ensure_all_started(:ecto_sql)

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
