defmodule Postcss.Comment do
  @moduledoc """
  Represents a CSS comment in the AST.

  ## Examples

      iex> comment = %Postcss.Comment{text: "This is a comment"}
      iex> comment.text
      "This is a comment"
  """

  defstruct [
    :text,
    :source,
    raws: %{}
  ]

  @type t :: %__MODULE__{
          text: String.t(),
          source: map() | nil,
          raws: map()
        }
end

defimpl String.Chars, for: Postcss.Comment do
  def to_string(%Postcss.Comment{text: text, raws: raws}) do
    left = Map.get(raws, :left, "")
    right = Map.get(raws, :right, "")
    "/*#{left}#{text}#{right}*/"
  end
end
