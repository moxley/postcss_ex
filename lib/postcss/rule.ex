defmodule Postcss.Rule do
  @moduledoc """
  Represents a CSS rule with a selector and declarations.

  Examples:
  - `.foo { color: red; }`
  - `#main, .sidebar { font-size: 12px; }`
  """

  alias Postcss.Declaration

  defstruct [
    :selector,
    :source,
    nodes: [],
    raws: %{}
  ]

  @type t :: %__MODULE__{
          selector: String.t(),
          nodes: [struct()],
          source: map() | nil,
          raws: map()
        }

  defimpl String.Chars do
    def to_string(rule) do
      if Enum.empty?(rule.nodes) do
        "#{rule.selector} {}"
      else
        declarations =
          rule.nodes
          |> Enum.map(fn node ->
            case node do
              %Declaration{} ->
                # Always add semicolon after declarations to match PostCSS behavior
                "  #{node};"

              _ ->
                "  #{node}"
            end
          end)
          |> Enum.join("\n")

        "#{rule.selector} {\n#{declarations}\n}"
      end
    end
  end
end
