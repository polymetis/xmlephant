defmodule Xmlephant.ExtensionTest do
  use ExUnit.Case, async: true

  describe "init/1 :decode_binary validation" do
    test "defaults to :copy when no option is given" do
      assert Xmlephant.Extension.init([]) == :copy
    end

    test "accepts :copy explicitly" do
      assert Xmlephant.Extension.init(decode_binary: :copy) == :copy
    end

    test "accepts :reference explicitly" do
      assert Xmlephant.Extension.init(decode_binary: :reference) == :reference
    end

    test "raises ArgumentError on unknown values" do
      assert_raise ArgumentError,
                   ~r/:decode_binary must be :copy or :reference/,
                   fn -> Xmlephant.Extension.init(decode_binary: :bogus) end
    end
  end
end
