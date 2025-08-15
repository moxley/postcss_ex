defmodule PostCSS.RootTest do
  use ExUnit.Case, async: true

  alias PostCSS.{Root, Rule, Declaration}

  describe "Root struct" do
    test "creates empty root" do
      root = %Root{}

      assert root.nodes == []
      assert root.type == :root
    end

    test "creates root with rules" do
      rule = %Rule{selector: ".foo"}
      root = %Root{nodes: [rule]}

      assert length(root.nodes) == 1
      assert hd(root.nodes) == rule
    end

    test "stringifies to CSS format" do
      decl = %Declaration{prop: "color", value: "red"}
      rule = %Rule{selector: ".foo", nodes: [decl]}
      root = %Root{nodes: [rule]}

      expected = ".foo {\n  color: red;\n}"
      assert to_string(root) == expected
    end

    test "stringifies multiple rules" do
      rule1 = %Rule{selector: ".foo", nodes: [%Declaration{prop: "color", value: "red"}]}
      rule2 = %Rule{selector: ".bar", nodes: [%Declaration{prop: "font-size", value: "12px"}]}
      root = %Root{nodes: [rule1, rule2]}

      expected = ".foo {\n  color: red;\n}\n.bar {\n  font-size: 12px;\n}"
      assert to_string(root) == expected
    end

    test "handles empty root" do
      root = %Root{}
      assert to_string(root) == ""
    end
  end
end
