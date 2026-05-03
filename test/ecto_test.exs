defmodule Xmlephant.EctoTest do
  use ExUnit.Case, async: true

  @moduletag :ecto

  alias Ecto.Adapters.SQL
  alias Xmlephant.Test.Repo

  defmodule XmlRow do
    use Ecto.Schema

    @primary_key {:id, :id, autogenerate: true}
    schema "xmlephant_ecto_test" do
      field :xml, :string
    end
  end

  setup do
    # Sandbox checkout owns a single connection per test; the TEMP table
    # lives in that connection's pg_temp namespace and disappears when the
    # sandbox transaction rolls back at test end.
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    SQL.query!(Repo, "CREATE TEMP TABLE xmlephant_ecto_test (id serial PRIMARY KEY, xml xml)", [])
    :ok
  end

  test "round-trips an XML binary through Repo.insert!/Repo.all" do
    xml = "<root>ecto-hello</root>"

    Repo.insert!(%XmlRow{xml: xml})

    [row] = Repo.all(XmlRow)
    assert row.xml == xml
  end
end
