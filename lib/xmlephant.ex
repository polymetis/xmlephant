defmodule Xmlephant do
  @moduledoc """
  A Postgrex extension for the PostgreSQL `xml` column type.

  Once installed, `xml` columns round-trip through Postgrex as plain
  Elixir binaries.

  ## Usage

  Define a Postgrex types module that includes the extension:

      Postgrex.Types.define(MyApp.PostgrexTypes, [Xmlephant.Extension])

  For Ecto, mix in the adapter's defaults:

      Postgrex.Types.define(
        MyApp.PostgrexTypes,
        [Xmlephant.Extension] ++ Ecto.Adapters.Postgres.extensions(),
        json: Jason
      )

  Then point Postgrex (or Ecto) at the types module:

      {:ok, pid} = Postgrex.start_link(types: MyApp.PostgrexTypes, ...)

  See `Xmlephant.Extension` for the configuration options accepted in
  the extensions list.
  """
end
