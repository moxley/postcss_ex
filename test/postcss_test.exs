defmodule PostcssTest do
  use ExUnit.Case, async: true
  doctest Postcss

  alias Postcss

  describe "parse/1" do
    test "parses simple CSS" do
      css = ".foo { color: red; }"
      root = Postcss.parse(css)

      assert %Postcss.Root{} = root
      assert length(root.nodes) == 1

      [rule] = root.nodes
      assert %Postcss.Rule{} = rule
      assert rule.selector == ".foo"
    end
  end

  describe "stringify/1" do
    test "stringifies CSS AST" do
      root = Postcss.parse(".foo { color: red; }")
      css_string = Postcss.stringify(root)

      assert is_binary(css_string)
      assert String.contains?(css_string, ".foo")
      assert String.contains?(css_string, "color")
      assert String.contains?(css_string, "red")
    end

    test "handles something more complex" do
      css = """
      @import url("https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400..900;1,400..900&display=swap");

      :root {
        /* Primary accent color */
        --accent-color: #2630ed;
        --accent-color-lighter: #5e67f2;
        --bg-color: #eeeef7;
      }
      """

      root = Postcss.parse(css)
      css_string = Postcss.stringify(root)

      assert css_string == css
    end
  end
end
