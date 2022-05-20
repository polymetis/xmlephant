defmodule XmlephantTest do
  use ExUnit.Case, async: true
  doctest Xmlephant

  setup do
    {:ok, pid} = Postgrex.start_link(Xmlephant.Test.Helper.opts())

    {:ok, _} =
      Postgrex.query(pid,
                     "DROP TABLE IF EXISTS xmlephant_test", [])

    {:ok, [pid: pid]}
  end

  test "insert xml as binary", context do
    pid = context[:pid]
    {:ok, _} =
      Postgrex.query(pid,
                     "CREATE TABLE xmlephant_test (id serial, xml xml)", [])

    {:ok, _} =
      Postgrex.query(pid,
                     "INSERT INTO xmlephant_test (xml) VALUES ($1)", ["<root>hello</root>"])

    {:ok, _} =
      Postgrex.query(pid,
                     "SELECT xml FROM xmlephant_test", [])

    {:ok, [xml: "<root>hello</root>"]}
  end
end
