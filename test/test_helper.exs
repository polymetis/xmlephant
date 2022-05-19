{:ok, _} = Application.ensure_all_started(:ecto_sql)

defmodule Geo.Test.Helper do
  def opts do
    [
      hostname: "localhost",
      username: "postgres",
      database: "xmlephant_test",
      types: Xmlephant.PostgrexTypes
    ]
  end
end


ExUnit.start()
