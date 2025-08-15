defmodule PostCSS.IntegrationTest do
  use ExUnit.Case, async: true

  alias PostCSS

  describe "full parse and stringify cycle" do
    test "simple declaration" do
      css = "color: red"
      root = PostCSS.parse(css)
      result = PostCSS.stringify(root)

      # Should contain the essential parts
      assert String.contains?(result, "color")
      assert String.contains?(result, "red")
    end

    test "simple rule" do
      css = ".foo { color: red; }"
      root = PostCSS.parse(css)
      result = PostCSS.stringify(root)

      assert String.contains?(result, ".foo")
      assert String.contains?(result, "color")
      assert String.contains?(result, "red")
      assert String.contains?(result, "{")
      assert String.contains?(result, "}")
    end

    test "multiple declarations" do
      css = ".foo { color: red; font-size: 12px; }"
      root = PostCSS.parse(css)
      result = PostCSS.stringify(root)

      assert String.contains?(result, "color: red")
      assert String.contains?(result, "font-size: 12px")
    end

    test "multiple rules" do
      css = ".foo { color: red; } .bar { font-size: 12px; }"
      root = PostCSS.parse(css)
      result = PostCSS.stringify(root)

      assert String.contains?(result, ".foo")
      assert String.contains?(result, ".bar")
      assert String.contains?(result, "color: red")
      assert String.contains?(result, "font-size: 12px")
    end

    test "important declarations" do
      css = ".foo { color: red !important; }"
      root = PostCSS.parse(css)
      result = PostCSS.stringify(root)

      assert String.contains?(result, "!important")
    end
  end

  describe "API convenience methods" do
    test "creating declarations" do
      decl = PostCSS.decl("color", "red")

      assert decl.prop == "color"
      assert decl.value == "red"
      assert decl.important == false
    end

    test "creating important declarations" do
      decl = PostCSS.decl("color", "red", important: true)

      assert decl.important == true
    end

    test "creating rules" do
      rule = PostCSS.rule(".foo")

      assert rule.selector == ".foo"
      assert rule.nodes == []
    end

    test "creating rules with declarations" do
      decl = PostCSS.decl("color", "red")
      rule = PostCSS.rule(".foo", [decl])

      assert rule.selector == ".foo"
      assert rule.nodes == [decl]
    end

    test "creating root nodes" do
      root = PostCSS.root()

      assert root.nodes == []
    end

    test "creating root with rules" do
      rule = PostCSS.rule(".foo")
      root = PostCSS.root([rule])

      assert root.nodes == [rule]
    end
  end

  describe "complex CSS examples" do
    test "nested-like CSS structure" do
      css = """
      .header {
        background: white;
        color: black;
      }
      .content {
        margin: 20px;
        padding: 10px;
      }
      """

      root = PostCSS.parse(css)
      result = PostCSS.stringify(root)

      # Should parse and regenerate successfully
      assert String.contains?(result, ".header")
      assert String.contains?(result, ".content")
      assert String.contains?(result, "background: white")
      assert String.contains?(result, "margin: 20px")
    end
  end
end
