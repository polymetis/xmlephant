defmodule Xmlephant.PropertyTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  # Xmlephant.Extension.encode/1 and decode/1 follow the Postgrex.Extension
  # contract: they return quoted case clauses, not callable functions. The
  # macros below splice those clauses into a `case` at this module's compile
  # time so the property exercises the real production code rather than a
  # hand-written re-implementation of the wire format.
  defmacrop wire_encode(value) do
    quote do
      case unquote(value), do: unquote(Xmlephant.Extension.encode(:state))
    end
  end

  defmacrop wire_decode(value) do
    quote do
      case unquote(value), do: unquote(Xmlephant.Extension.decode(:copy))
    end
  end

  property "encode/decode round-trips arbitrary binaries" do
    check all bin <- StreamData.binary() do
      encoded = IO.iodata_to_binary(wire_encode(bin))
      assert wire_decode(encoded) == bin
    end
  end
end
