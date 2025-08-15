defmodule Postcss.Declaration do
  @moduledoc """
  Represents a CSS declaration (property: value pair).

  Examples:
  - `color: red`
  - `font-size: 12px !important`
  """

  defstruct [
    :prop,
    :value,
    :source,
    important: false,
    raws: %{}
  ]

  @type t :: %__MODULE__{
          prop: String.t(),
          value: String.t(),
          important: boolean(),
          source: map() | nil,
          raws: map()
        }

  defimpl String.Chars do
    def to_string(decl) do
      between = Map.get(decl.raws, :between, ": ")
      value_part = if decl.important, do: "#{decl.value} !important", else: decl.value

      "#{decl.prop}#{between}#{value_part}"
    end
  end
end
