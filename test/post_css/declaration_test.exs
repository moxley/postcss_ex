defmodule PostCSS.DeclarationTest do
  use ExUnit.Case, async: true

  alias PostCSS.Declaration

  describe "Declaration struct" do
    test "creates declaration with prop and value" do
      decl = %Declaration{prop: "color", value: "red"}

      assert decl.prop == "color"
      assert decl.value == "red"
      assert decl.important == false
    end

    test "creates declaration with important flag" do
      decl = %Declaration{prop: "color", value: "red", important: true}

      assert decl.important == true
    end

    test "stringifies to CSS format" do
      decl = %Declaration{prop: "color", value: "red"}
      assert to_string(decl) == "color: red"
    end

    test "stringifies with important flag" do
      decl = %Declaration{prop: "color", value: "red", important: true}
      assert to_string(decl) == "color: red !important"
    end

    test "handles raws for formatting" do
      decl = %Declaration{
        prop: "color",
        value: "red",
        raws: %{before: "  ", after: " ", between: " : "}
      }

      assert to_string(decl) == "color : red"
    end
  end
end
