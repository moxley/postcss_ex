defmodule Postcss.Root do
  @moduledoc """
  Represents the root node of a PostCSS AST.

  The root contains all top-level rules, at-rules, and comments.
  """

  defstruct [
    :source,
    nodes: [],
    raws: %{},
    type: :root
  ]

  @type t :: %__MODULE__{
          nodes: [struct()],
          source: map() | nil,
          raws: map(),
          type: :root
        }

  defimpl String.Chars do
    def to_string(root) do
      # Follow PostCSS root() method: this.body(node) + node.raws.after
      body_content = body(root)
      after_content = Map.get(root.raws || %{}, :after, "")

      "#{body_content}#{after_content}"
    end

    # Implements PostCSS body() method logic
    defp body(node) do
      alias Postcss.Raws

      if Enum.empty?(node.nodes) do
        ""
      else
        # Find last non-comment node for semicolon logic
        last_non_comment_index = find_last_non_comment_index(node.nodes)

        # Get semicolon setting for the container
        container_semicolon = Map.get(node.raws || %{}, :semicolon, false)

        node.nodes
        |> Enum.with_index()
        |> Enum.map(fn {child, index} ->
          # Get "before" whitespace using PostCSS raw() logic
          # Special case: first child of root gets empty "before" (PostCSS logic)
          before =
            if index == 0 do
              # First rule in root gets empty string
              case Map.get(child.raws || %{}, :before) do
                nil -> ""
                value -> value
              end
            else
              raw(child, :before)
            end

          # Stringify the child
          child_str = Kernel.to_string(child)

          # Add semicolon following PostCSS logic: last !== i || semicolon
          needs_semicolon = index != last_non_comment_index or container_semicolon

          semicolon_str =
            if needs_semicolon and match?(%Postcss.Declaration{}, child), do: ";", else: ""

          "#{before}#{child_str}#{semicolon_str}"
        end)
        |> Enum.join("")
      end
    end

    # Find the index of the last non-comment node
    defp find_last_non_comment_index(nodes) do
      nodes
      |> Enum.with_index()
      |> Enum.reverse()
      |> Enum.find(fn {node, _index} -> not match?(%Postcss.Comment{}, node) end)
      |> case do
        {_node, index} -> index
        nil -> -1
      end
    end

    # Implements PostCSS raw() method logic for "before" values
    defp raw(node, :before) do
      alias Postcss.Raws

      # Check if node has its own "before" raw
      case Map.get(node.raws || %{}, :before) do
        nil ->
          # Apply PostCSS logic: first rule in root gets ""
          # For now, we'll use a simple fallback since we don't have parent references
          case node do
            %Postcss.Declaration{} ->
              Raws.get(node, :before, Map.get(Raws.defaults(), :before_decl))

            %Postcss.Comment{} ->
              Raws.get(node, :before, Map.get(Raws.defaults(), :before_comment))

            _ ->
              Raws.get(node, :before, Map.get(Raws.defaults(), :before_rule))
          end

        value ->
          value
      end
    end
  end
end
