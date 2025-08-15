defmodule PostCSS.Raws do
  @moduledoc """
  Utilities for handling PostCSS raw formatting preservation.

  This module provides default formatting values and utilities for
  preserving whitespace and formatting during parsing and stringification.
  """

  @doc """
  Default raw formatting values, based on PostCSS DEFAULT_RAW.

  These match the defaults from postcss/lib/stringifier.js
  """
  def defaults do
    %{
      after: "\n",
      before_close: "\n",
      before_comment: "\n",
      before_decl: "\n",
      before_open: " ",
      before_rule: "\n",
      colon: ": ",
      comment_left: " ",
      comment_right: " ",
      empty_body: "",
      indent: "  ",
      semicolon: false
    }
  end

  @doc """
  Gets a raw value from a node's raws, falling back to default if not present.

  This follows the PostCSS Node.js logic for handling special cases.
  """
  def get(node, key, fallback \\ nil) do
    # First check if the node has the raw value
    case Map.get(node.raws || %{}, key) do
      nil ->
        # Apply PostCSS logic for special cases
        case key do
          :before -> get_before_value(node, fallback)
          _ -> fallback || Map.get(defaults(), key)
        end

      value ->
        value
    end
  end

  # Implements PostCSS logic for "before" values
  defp get_before_value(_node, fallback) do
    # For now, we don't have parent references, so we can't implement
    # the full PostCSS logic. We'll use fallback or default.
    fallback || Map.get(defaults(), :before_rule)
  end

  @doc """
  Sets a raw value in a node's raws map.
  """
  def put(node, key, value) do
    raws = node.raws || %{}
    %{node | raws: Map.put(raws, key, value)}
  end

  @doc """
  Determines if a node should have a semicolon after it.
  """
  def has_semicolon?(node, is_last \\ false) do
    case get(node, :semicolon) do
      true ->
        true

      false ->
        false

      nil ->
        # Default behavior: semicolon for declarations, but not for last declaration in some contexts
        case node do
          %PostCSS.Declaration{} -> not is_last
          _ -> false
        end
    end
  end

  @doc """
  Gets indentation for a node based on its depth and context.
  """
  def get_indent(node, depth \\ 1) do
    base_indent = get(node, :indent, "  ")
    String.duplicate(base_indent, depth)
  end
end
