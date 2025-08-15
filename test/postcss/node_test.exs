defmodule Postcss.NodeTest do
  use ExUnit.Case, async: true

  alias Postcss
  alias Postcss.{Node, Declaration, Rule, Root}

  describe "Node protocol" do
    test "nodes implement to_string/1" do
      decl = %Declaration{prop: "color", value: "red"}
      assert to_string(decl) == "color: red"
    end

    test "nodes can be cloned" do
      decl = %Declaration{prop: "color", value: "red", source: %{line: 1}}
      cloned = Node.clone(decl)

      assert cloned.prop == "color"
      assert cloned.value == "red"
      assert cloned.source == %{line: 1}
      # In Elixir, structs with same values are equal, so we test that cloning works
      assert cloned == decl
    end

    test "nodes can be cloned with overrides" do
      decl = %Declaration{prop: "color", value: "red"}
      cloned = Node.clone(decl, %{value: "blue"})

      assert cloned.prop == "color"
      assert cloned.value == "blue"
    end

    test "nodes have type information" do
      decl = %Declaration{prop: "color", value: "red"}
      rule = %Rule{selector: ".foo"}
      root = %Root{}

      assert Node.type(decl) == :declaration
      assert Node.type(rule) == :rule
      assert Node.type(root) == :root
    end
  end
end
