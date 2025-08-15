defmodule Postcss.Node do
  @moduledoc """
  Protocol for PostCSS AST nodes.

  All nodes in the PostCSS AST implement this protocol to provide
  common functionality like cloning, type identification, and tree navigation.
  """

  @doc """
  Returns the type of the node as an atom.
  """
  @callback type(node :: struct()) :: atom()

  @doc """
  Clones a node, optionally with overrides.
  """
  def clone(node, overrides \\ %{}) do
    node
    |> Map.from_struct()
    |> Map.merge(overrides)
    |> then(&struct(node.__struct__, &1))
  end

  @doc """
  Returns the type of the node.
  """
  def type(%{__struct__: Postcss.Declaration}), do: :declaration
  def type(%{__struct__: Postcss.Rule}), do: :rule
  def type(%{__struct__: Postcss.Root}), do: :root
  def type(%{__struct__: Postcss.AtRule}), do: :at_rule
  def type(%{__struct__: Postcss.Comment}), do: :comment
end
