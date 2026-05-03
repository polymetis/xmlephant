Postgrex.Types.define(
  Xmlephant.PostgrexTypes,
  [Xmlephant.Extension], []
)

Postgrex.Types.define(
  Xmlephant.PostgrexTypes.Reference,
  [{Xmlephant.Extension, [decode_binary: :reference]}],
  []
)
