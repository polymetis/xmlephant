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

  test "attempt to insert non xml as binary", context do
    pid = context[:pid]
    {:ok, _} =
      Postgrex.query(pid,
                     "CREATE TABLE xmlephant_test (id serial, xml xml)", [])

    {:error,  %Postgrex.Error{postgres: %{code: :invalid_xml_content}}} =
      Postgrex.query(pid,
                     "INSERT INTO xmlephant_test (xml) VALUES ($1)", ["<root>hello</oot>"])

  end

  test "query xml with xmltable", context do
    pid = context[:pid]
    {:ok, content} = File.read("test/fixtures/rocinante.xml")


    {:ok, _} =
      Postgrex.query(pid,
                     "CREATE TABLE xmlephant_test (id serial, xml xml)", [])

    {:ok, _} =
      Postgrex.query(pid,
                     "INSERT INTO xmlephant_test (xml) VALUES ($1)", [content])

    {:ok, %Postgrex.Result{
      rows: [
        [
          1,
          "41: \"Babylon's Ashes\"",
          "theincomparable/salvage/41",
          "The Incomparable",
          "https://dts.podtrac.com/redirect.mp3/www.theincomparable.com/podcast/salvage41.mp3",
          %Postgrex.Interval{days: 0, microsecs: 0, months: 0, secs: 198180}
        ] | _ ]}} =
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

  end
end
