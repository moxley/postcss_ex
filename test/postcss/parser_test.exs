defmodule Postcss.ParserTest do
  use ExUnit.Case, async: true

  alias Postcss.{Parser, Root, Rule, Declaration}

  describe "basic parsing" do
    test "parses simple declaration" do
      css = "color: red"
      root = Parser.parse(css)

      assert %Root{} = root
      assert length(root.nodes) == 1

      [decl] = root.nodes
      assert %Declaration{} = decl
      assert decl.prop == "color"
      assert decl.value == "red"
    end

    test "parses rule with declaration" do
      css = ".foo { color: red; }"
      root = Parser.parse(css)

      assert %Root{} = root
      assert length(root.nodes) == 1

      [rule] = root.nodes
      assert %Rule{} = rule
      assert rule.selector == ".foo"
      assert length(rule.nodes) == 1

      [decl] = rule.nodes
      assert %Declaration{} = decl
      assert decl.prop == "color"
      assert decl.value == "red"
    end

    test "parses multiple declarations" do
      css = ".foo { color: red; font-size: 12px; }"
      root = Parser.parse(css)

      [rule] = root.nodes
      assert length(rule.nodes) == 2

      [decl1, decl2] = rule.nodes
      assert decl1.prop == "color"
      assert decl1.value == "red"
      assert decl2.prop == "font-size"
      assert decl2.value == "12px"
    end

    test "parses multiple rules" do
      css = ".foo { color: red; } .bar { font-size: 12px; }"
      root = Parser.parse(css)

      assert length(root.nodes) == 2

      [rule1, rule2] = root.nodes
      assert rule1.selector == ".foo"
      assert rule2.selector == ".bar"
    end

    test "parses empty rule" do
      css = ".foo {}"
      root = Parser.parse(css)

      [rule] = root.nodes
      assert rule.selector == ".foo"
      assert rule.nodes == []
    end

    test "handles important declarations" do
      css = ".foo { color: red !important; }"
      root = Parser.parse(css)

      [rule] = root.nodes
      [decl] = rule.nodes

      assert decl.prop == "color"
      assert decl.value == "red"
      assert decl.important == true
    end

    test "parses complex selectors" do
      css = ".foo .bar, #baz:hover { color: red; }"
      root = Parser.parse(css)

      [rule] = root.nodes
      assert rule.selector == ".foo .bar, #baz:hover"
    end

    test "handles empty input" do
      root = Parser.parse("")
      assert %Root{nodes: []} = root
    end

    test "handles whitespace only" do
      root = Parser.parse("   \n\t  ")
      assert %Root{nodes: []} = root
    end
  end

  describe "error handling" do
    test "handles unclosed braces gracefully" do
      css = ".foo { color: red;"

      assert_raise Postcss.CssSyntaxError, fn ->
        Parser.parse(css)
      end
    end

    test "handles unexpected closing brace" do
      css = "color: red; }"

      assert_raise Postcss.CssSyntaxError, fn ->
        Parser.parse(css)
      end
    end
  end
end
