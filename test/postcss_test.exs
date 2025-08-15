defmodule PostcssTest do
  use ExUnit.Case, async: true
  doctest Postcss

  alias Postcss

  test "parses simple CSS" do
    css = ".foo { color: red; }"
    root = Postcss.parse(css)

    assert %Postcss.Root{} = root
    assert length(root.nodes) == 1

    [rule] = root.nodes
    assert %Postcss.Rule{} = rule
    assert rule.selector == ".foo"
  end

  test "stringifies CSS AST" do
    root = Postcss.parse(".foo { color: red; }")
    css_string = Postcss.stringify(root)

    assert is_binary(css_string)
    assert String.contains?(css_string, ".foo")
    assert String.contains?(css_string, "color")
    assert String.contains?(css_string, "red")
  end
end
