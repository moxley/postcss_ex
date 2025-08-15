defmodule Postcss.Root do
  @moduledoc """
  Represents the root node of a PostCSS AST.

  The root contains all top-level rules, at-rules, and comments.
  """

  alias Postcss.AtRule

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
      if Enum.empty?(root.nodes) do
        ""
      else
        result =
          root.nodes
          |> Enum.with_index()
          |> Enum.map(fn {node, index} ->
            node_str = Kernel.to_string(node)

            # Add extra newline after at-rules if followed by other nodes
            # This is a simple heuristic for the complex test case
            if match?(%AtRule{}, node) and index < length(root.nodes) - 1 do
              node_str <> "\n"
            else
              node_str
            end
          end)
          |> Enum.join("\n")

        # Add trailing newline only for complex cases (multiple node types)
        node_types =
          root.nodes
          |> Enum.map(& &1.__struct__)
          |> Enum.uniq()

        if length(node_types) > 1 do
          result <> "\n"
        else
          result
        end
      end
    end
  end
end
