{:ok, _} = Application.ensure_all_started(:ecto_sql)

defmodule Xmlephant.Test.Helper do
  def opts do
    [
      hostname: "localhost",
      username: "postgres",
      password: "postgres",
      database: "xmlephant_test",
      types: Xmlephant.PostgrexTypes
    ]
  end
end


ExUnit.start()
