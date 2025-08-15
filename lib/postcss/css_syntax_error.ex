defmodule Postcss.CssSyntaxError do
  @moduledoc """
  Exception raised when CSS parsing fails.
  """

  defexception [:message, :line, :column, :source]

  @type t :: %__MODULE__{
          message: String.t(),
          line: integer() | nil,
          column: integer() | nil,
          source: String.t() | nil
        }

  def new(message, line \\ nil, column \\ nil, source \\ nil) do
    %__MODULE__{
      message: message,
      line: line,
      column: column,
      source: source
    }
  end
end
