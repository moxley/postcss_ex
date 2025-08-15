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
      if Enum.empty?(root.nodes) do
        ""
      else
        root.nodes
        |> Enum.map(&Kernel.to_string/1)
        |> Enum.join("\n")
      end
    end
  end
end
