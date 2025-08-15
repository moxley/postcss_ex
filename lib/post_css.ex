defmodule PostCSS do
  @moduledoc """
  PostCSS for Elixir - A tool for transforming CSS with plugins.

  This is an Elixir implementation of the popular [PostCSS](https://postcss.org/) library,
  providing CSS parsing, AST manipulation, and stringification.
  """

  alias PostCSS.{Parser, Root, Rule, Declaration, AtRule, Comment}

  @doc """
  Parses CSS string into a PostCSS AST.

  ## Examples

      iex> root = PostCSS.parse("color: red")
      iex> %PostCSS.Root{nodes: [node]} = root
      iex> node
      %PostCSS.Declaration{prop: "color", value: "red"}
  """
  def parse(css) when is_binary(css) do
    Parser.parse(css)
  end

  @doc """
  Converts a PostCSS AST back to CSS string.

  ## Examples

      iex> root = PostCSS.parse(".foo { color: red; }")
      iex> PostCSS.stringify(root)
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

      iex> PostCSS.decl("color", "red")
      %PostCSS.Declaration{prop: "color", value: "red"}

      iex> PostCSS.decl("color", "red", important: true)
      %PostCSS.Declaration{prop: "color", value: "red", important: true}
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

      iex> PostCSS.rule(".foo")
      %PostCSS.Rule{selector: ".foo", nodes: []}

      iex> decl = PostCSS.decl("color", "red")
      iex> PostCSS.rule(".foo", [decl])
      %PostCSS.Rule{selector: ".foo", nodes: [decl]}
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

      iex> PostCSS.root()
      %PostCSS.Root{nodes: []}

      iex> rule = PostCSS.rule(".foo")
      iex> PostCSS.root([rule])
      %PostCSS.Root{nodes: [rule]}
  """
  def root(nodes \\ []) do
    %Root{nodes: nodes}
  end

  @doc """
  Creates a new at-rule node.

  ## Examples

      iex> PostCSS.at_rule("import", "url(\\"styles.css\\")")
      %PostCSS.AtRule{name: "import", params: "url(\\"styles.css\\")"}

      iex> decl = PostCSS.decl("color", "red")
      iex> PostCSS.at_rule("media", "screen", [decl])
      %PostCSS.AtRule{name: "media", params: "screen", nodes: [decl]}
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

      iex> comment = PostCSS.comment("This is a comment")
      iex> comment.text
      "This is a comment"
  """
  def comment(text) do
    %Comment{text: text}
  end
end
