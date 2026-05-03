defmodule Xmlephant.Extension do
  @moduledoc """
  Postgrex extension that round-trips PostgreSQL `xml` columns as Elixir
  binaries.

  The extension does not parse XML in Elixir — bytes you insert are the
  bytes you read back. PostgreSQL parses on insert (well-formedness only)
  and rejects malformed input with `:invalid_xml_content`.

  See `Xmlephant` for installation; this module documents the option
  accepted in the `Postgrex.Types.define/3` extensions list.

  ## Options

    * `:decode_binary` — `:copy` (default) or `:reference`. Mirrors
      Postgrex's built-in binary extension. With `:copy` the decoded value
      is detached from the connection's receive buffer with
      `:binary.copy/1`, making it safe to retain across messages. With
      `:reference` the decoded value is a sub-binary into that buffer —
      the buffer is reused on the next message, so only choose
      `:reference` when you fully consume the value before the connection
      receives anything else.

  ## Notes for implementers

  Following the `Postgrex.Extension` contract, `encode/1` and `decode/1`
  return quoted match clauses that Postgrex splices into a generated
  dispatcher at compile time. They are not callable functions in the
  usual sense.
  """

  @behaviour Postgrex.Extension

  def init(opts) do
    case Keyword.get(opts, :decode_binary, :copy) do
      :copy ->
        :copy

      :reference ->
        :reference

      other ->
        raise ArgumentError,
              "Xmlephant.Extension :decode_binary must be :copy or :reference, got: #{inspect(other)}"
    end
  end

  def matching(_state), do: [type: "xml"]

  def format(_state), do: :text

  def encode(_state) do
    quote do
      bin when is_binary(bin) ->
        [<<byte_size(bin)::signed-size(32)>> | bin]

      other ->
        raise ArgumentError,
              "Xmlephant.Extension expected a binary for the xml type, got: #{inspect(other)}"
    end
  end

  def decode(:reference) do
    quote do
      <<len::signed-size(32), bin::binary-size(len)>> ->
        bin
    end
  end

  def decode(:copy) do
    quote do
      <<len::signed-size(32), bin::binary-size(len)>> ->
        :binary.copy(bin)
    end
  end
end
