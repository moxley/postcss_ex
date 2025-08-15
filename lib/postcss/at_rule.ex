defmodule Postcss.AtRule do
  @moduledoc """
  Represents a CSS at-rule like @import, @media, @keyframes, etc.

  Examples:
  - `@import url("styles.css");`
  - `@media screen { ... }`
  - `@keyframes slide { ... }`
  """

  defstruct [
    :name,
    :params,
    :source,
    nodes: [],
    raws: %{}
  ]

  @type t :: %__MODULE__{
          name: String.t(),
          params: String.t() | nil,
          nodes: [struct()],
          source: map() | nil,
          raws: map()
        }

  defimpl String.Chars do
    def to_string(at_rule) do
      rule_start = "@#{at_rule.name}"

      rule_with_params =
        if at_rule.params do
          "#{rule_start} #{at_rule.params}"
        else
          rule_start
        end

      if Enum.empty?(at_rule.nodes) do
        "#{rule_with_params};"
      else
        declarations =
          at_rule.nodes
          |> Enum.with_index()
          |> Enum.map(fn {node, index} ->
            suffix = if index < length(at_rule.nodes) - 1, do: ";", else: ""
            "  #{node}#{suffix}"
          end)
          |> Enum.join("\n")

        "#{rule_with_params} {\n#{declarations}\n}"
      end
    end
  end
end

