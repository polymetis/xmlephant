defmodule XmlephantTest do
  use ExUnit.Case, async: true
  doctest Xmlephant

  setup do
    {:ok, pid} = Postgrex.start_link(Xmlephant.Test.Helper.opts())
    {:ok, [pid: pid]}
  end

  test "round-trips an XML binary through INSERT and SELECT", context do
    pid = context[:pid]

    {:ok, _} =
      Postgrex.query(pid, "CREATE TEMP TABLE xmlephant_test (id serial, xml xml)", [])

    {:ok, _} =
      Postgrex.query(pid,
                     "INSERT INTO xmlephant_test (xml) VALUES ($1)",
                     ["<root>hello</root>"])

    {:ok, %Postgrex.Result{rows: [[xml]]}} =
      Postgrex.query(pid, "SELECT xml FROM xmlephant_test", [])

    assert xml == "<root>hello</root>"
  end

  test "round-trips an XML binary when :decode_binary is :reference" do
    {:ok, pid} =
      Postgrex.start_link(Xmlephant.Test.Helper.opts(Xmlephant.PostgrexTypes.Reference))

    {:ok, _} =
      Postgrex.query(pid, "CREATE TEMP TABLE xmlephant_test (id serial, xml xml)", [])

    {:ok, _} =
      Postgrex.query(pid,
                     "INSERT INTO xmlephant_test (xml) VALUES ($1)",
                     ["<root>hello</root>"])

    {:ok, %Postgrex.Result{rows: [[xml]]}} =
      Postgrex.query(pid, "SELECT xml FROM xmlephant_test", [])

    assert xml == "<root>hello</root>"
  end

  test "attempt to insert non xml as binary", context do
    pid = context[:pid]
    {:ok, _} =
      Postgrex.query(pid,
                     "CREATE TEMP TABLE xmlephant_test (id serial, xml xml)", [])

    {:error,  %Postgrex.Error{postgres: %{code: :invalid_xml_content}}} =
      Postgrex.query(pid,
                     "INSERT INTO xmlephant_test (xml) VALUES ($1)", ["<root>hello</oot>"])

  end

  test "decodes inserted XML so XMLTABLE can extract typed columns", context do
    pid = context[:pid]
    {:ok, content} = File.read(Path.join(__DIR__, "fixtures/rocinante.xml"))

    {:ok, _} =
      Postgrex.query(pid, "CREATE TEMP TABLE xmlephant_test (id serial, xml xml)", [])

    {:ok, _} =
      Postgrex.query(pid,
                     "INSERT INTO xmlephant_test (xml) VALUES ($1)",
                     [content])

    {:ok, %Postgrex.Result{rows: rows}} =
      Postgrex.query(pid,
                     """
                     SELECT xmltable.*
                     FROM xmlephant_test, XMLTABLE( XMLNAMESPACES('http://purl.org/rss/1.0/modules/content/' AS content,
                                                                  'http://www.itunes.com/dtds/podcast-1.0.dtd' AS itunes),
                                         'rss/channel/item' PASSING xml
                     COLUMNS
                       id FOR ORDINALITY,
                       title text PATH 'title',
                       guid text PATH 'guid',
                       author text PATH 'itunes:author',
                       file text PATH 'enclosure/@url',
                       length interval PATH 'itunes:duration');
                     """, [])

    assert length(rows) >= 2,
           "expected XMLTABLE to extract at least 2 items; got #{length(rows)}"

    [first, second | _] = rows

    assert first == [
             1,
             "41: \"Babylon's Ashes\"",
             "theincomparable/salvage/41",
             "The Incomparable",
             "https://dts.podtrac.com/redirect.mp3/www.theincomparable.com/podcast/salvage41.mp3",
             %Postgrex.Interval{days: 0, microsecs: 0, months: 0, secs: 198180}
           ]

    # Second row should have ordinal 2 and same publisher; proves iteration.
    assert [2, _title, _guid, "The Incomparable", _file, _length] = second
  end
end
