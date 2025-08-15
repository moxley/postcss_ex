defmodule Postcss.RuleTest do
  use ExUnit.Case, async: true

  alias Postcss.{Rule, Declaration}

  describe "Rule struct" do
    test "creates rule with selector" do
      rule = %Rule{selector: ".foo"}

      assert rule.selector == ".foo"
      assert rule.nodes == []
    end

    test "creates rule with declarations" do
      decl = %Declaration{prop: "color", value: "red"}
      rule = %Rule{selector: ".foo", nodes: [decl]}

      assert length(rule.nodes) == 1
      assert hd(rule.nodes) == decl
    end

    test "stringifies to CSS format" do
      decl = %Declaration{prop: "color", value: "red"}
      rule = %Rule{selector: ".foo", nodes: [decl]}

      expected = ".foo {\n  color: red\n}"
      assert to_string(rule) == expected
    end

    test "stringifies empty rule" do
      rule = %Rule{selector: ".foo"}

      expected = ".foo {}"
      assert to_string(rule) == expected
    end

    test "handles multiple declarations" do
      decl1 = %Declaration{prop: "color", value: "red"}
      decl2 = %Declaration{prop: "font-size", value: "12px"}
      rule = %Rule{selector: ".foo", nodes: [decl1, decl2]}

      expected = ".foo {\n  color: red;\n  font-size: 12px\n}"
      assert to_string(rule) == expected
    end

    test "handles raws for formatting" do
      rule = %Rule{
        selector: ".foo",
        raws: %{before: "\n", after: "\n", between: " "}
      }

      expected = ".foo {}"
      assert to_string(rule) == expected
    end
  end
end
