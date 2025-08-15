defmodule Postcss do
  @moduledoc """
  PostCSS for Elixir - A tool for transforming CSS with plugins.

  This is an Elixir implementation of the popular PostCSS library,
  providing CSS parsing, AST manipulation, and stringification.
  """

  alias Postcss.{Parser, Root, Rule, Declaration, AtRule, Comment}

  @doc """
  Parses CSS string into a PostCSS AST.

  ## Examples

      iex> root = Postcss.parse("color: red")
      iex> [decl] = root.nodes
      iex> decl.prop
      "color"
      iex> decl.value
      "red"
  """
  def parse(css) when is_binary(css) do
    Parser.parse(css)
  end

  @doc """
  Converts a PostCSS AST back to CSS string.

  ## Examples

      iex> root = Postcss.parse(".foo { color: red; }")
      iex> Postcss.stringify(root)
      ".foo {\\n  color: red;\\n}"
  """
  def stringify(%Root{} = root) do
    to_string(root)
  end

  def stringify(node) do
    to_string(node)
  end

  @doc """
  Creates a new declaration node.

  ## Examples

      iex> Postcss.decl("color", "red")
      %Postcss.Declaration{prop: "color", value: "red"}

      iex> Postcss.decl("color", "red", important: true)
      %Postcss.Declaration{prop: "color", value: "red", important: true}
  """
  def decl(prop, value, opts \\ []) do
    %Declaration{
      prop: prop,
      value: value,
      important: Keyword.get(opts, :important, false)
    }
  end

  @doc """
  Creates a new rule node.

  ## Examples

      iex> Postcss.rule(".foo")
      %Postcss.Rule{selector: ".foo", nodes: []}

      iex> decl = Postcss.decl("color", "red")
      iex> Postcss.rule(".foo", [decl])
      %Postcss.Rule{selector: ".foo", nodes: [decl]}
  """
  def rule(selector, nodes \\ []) do
    %Rule{
      selector: selector,
      nodes: nodes
    }
  end

  @doc """
  Creates a new root node.

  ## Examples

      iex> Postcss.root()
      %Postcss.Root{nodes: []}

      iex> rule = Postcss.rule(".foo")
      iex> Postcss.root([rule])
      %Postcss.Root{nodes: [rule]}
  """
  def root(nodes \\ []) do
    %Root{nodes: nodes}
  end

  @doc """
  Creates a new at-rule node.

  ## Examples

      iex> Postcss.at_rule("import", "url(\\"styles.css\\")")
      %Postcss.AtRule{name: "import", params: "url(\\"styles.css\\")"}

      iex> decl = Postcss.decl("color", "red")
      iex> Postcss.at_rule("media", "screen", [decl])
      %Postcss.AtRule{name: "media", params: "screen", nodes: [decl]}
  """
  def at_rule(name, params \\ nil, nodes \\ []) do
    %AtRule{
      name: name,
      params: params,
      nodes: nodes
    }
  end

  @doc """
  Creates a new comment node.

  ## Examples

      iex> comment = Postcss.comment("This is a comment")
      iex> comment.text
      "This is a comment"
  """
  def comment(text) do
    %Comment{text: text}
  end
end
