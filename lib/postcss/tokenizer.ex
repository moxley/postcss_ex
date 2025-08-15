defmodule Postcss.Tokenizer do
  @moduledoc """
  CSS Tokenizer for PostCSS.

  Converts CSS strings into a list of tokens that can be processed by the parser.
  """

  @doc """
  Tokenizes a CSS string into a list of tokens.

  Each token is a tuple with the format:
  - `{type, value, start_pos}` for single character tokens
  - `{type, value, start_pos, end_pos}` for multi-character tokens
  """
  def tokenize(css) when is_binary(css) do
    css
    |> String.to_charlist()
    |> tokenize_chars([], 0)
    |> Enum.reverse()
  end

  defp tokenize_chars([], acc, _pos), do: acc

  defp tokenize_chars([char | rest], acc, pos) do
    case char do
      # Whitespace
      c when c in [?\s, ?\t, ?\n, ?\r, ?\f] ->
        {space, remaining, new_pos} = consume_whitespace([char | rest], pos)
        tokenize_chars(remaining, [{:space, space, pos} | acc], new_pos)

      # Braces
      ?{ ->
        tokenize_chars(rest, [{:open_brace, "{", pos} | acc], pos + 1)

      ?} ->
        tokenize_chars(rest, [{:close_brace, "}", pos} | acc], pos + 1)

      # Other punctuation
      ?: ->
        tokenize_chars(rest, [{:colon, ":", pos} | acc], pos + 1)

      ?; ->
        tokenize_chars(rest, [{:semicolon, ";", pos} | acc], pos + 1)

      ?, ->
        tokenize_chars(rest, [{:comma, ",", pos} | acc], pos + 1)

      # Parentheses
      ?\( ->
        tokenize_chars(rest, [{:open_paren, "(", pos} | acc], pos + 1)

      ?\) ->
        tokenize_chars(rest, [{:close_paren, ")", pos} | acc], pos + 1)

      ?# ->
        {word, remaining, new_pos} = consume_word([char | rest], pos)
        tokenize_chars(remaining, [{:word, word, pos, new_pos - 1} | acc], new_pos)

      # Comments
      ?/ ->
        case rest do
          [?* | _] ->
            {comment, remaining, new_pos} = consume_comment([char | rest], pos)
            tokenize_chars(remaining, [{:comment, comment, pos, new_pos - 1} | acc], new_pos)

          _ ->
            {word, remaining, new_pos} = consume_word([char | rest], pos)
            tokenize_chars(remaining, [{:word, word, pos, new_pos - 1} | acc], new_pos)
        end

      # Strings
      c when c in [?", ?'] ->
        {string, remaining, new_pos} = consume_string([char | rest], pos, char)
        tokenize_chars(remaining, [{:string, string, pos, new_pos - 1} | acc], new_pos)

      # At-rules
      ?@ ->
        {word, remaining, new_pos} = consume_word([char | rest], pos)
        tokenize_chars(remaining, [{:at_word, word, pos, new_pos - 1} | acc], new_pos)

      # Words/identifiers
      _ ->
        {word, remaining, new_pos} = consume_word([char | rest], pos)
        tokenize_chars(remaining, [{:word, word, pos, new_pos - 1} | acc], new_pos)
    end
  end

  defp consume_whitespace(chars, start_pos) do
    consume_while(chars, start_pos, fn
      c when c in [?\s, ?\t, ?\n, ?\r, ?\f] -> true
      _ -> false
    end)
  end

  defp consume_comment([?/, ?* | rest], start_pos) do
    case find_comment_end(rest, []) do
      {comment_body, remaining} ->
        comment = "/*" <> List.to_string(comment_body) <> "*/"
        end_pos = start_pos + String.length(comment) - 1
        {comment, remaining, end_pos + 1}

      :not_found ->
        # Unclosed comment - treat as word for now
        consume_word([?/, ?* | rest], start_pos)
    end
  end

  defp find_comment_end([], _acc), do: :not_found
  defp find_comment_end([?*, ?/ | rest], acc), do: {Enum.reverse(acc), rest}
  defp find_comment_end([char | rest], acc), do: find_comment_end(rest, [char | acc])

  defp consume_string([quote | rest], start_pos, quote_char) do
    case find_string_end(rest, start_pos + 1, quote_char) do
      {end_pos, remaining} ->
        string_length = end_pos - start_pos + 1
        string_chars = Enum.slice([quote | rest], 0, string_length)
        {List.to_string(string_chars), remaining, end_pos + 1}

      :not_found ->
        # Unclosed string - consume until end or newline
        consume_until_newline([quote | rest], start_pos)
    end
  end

  defp find_string_end([], _pos, _quote), do: :not_found

  defp find_string_end([char | rest], pos, quote) when char == quote do
    {pos, rest}
  end

  defp find_string_end([?\\ | [_escaped | rest]], pos, quote) do
    # Skip escaped character
    find_string_end(rest, pos + 2, quote)
  end

  defp find_string_end([?\n | _rest], _pos, _quote), do: :not_found

  defp find_string_end([_char | rest], pos, quote) do
    find_string_end(rest, pos + 1, quote)
  end

  defp consume_word(chars, start_pos) do
    consume_while(chars, start_pos, fn
      c when c in [?\s, ?\t, ?\n, ?\r, ?\f, ?{, ?}, ?:, ?;, ?", ?', ?/, ?\(, ?\)] -> false
      _ -> true
    end)
  end

  defp consume_while(chars, start_pos, predicate) do
    consume_while(chars, start_pos, predicate, [])
  end

  defp consume_while([], pos, _predicate, acc) do
    {acc |> Enum.reverse() |> List.to_string(), [], pos}
  end

  defp consume_while([char | rest], pos, predicate, acc) do
    if predicate.(char) do
      consume_while(rest, pos + 1, predicate, [char | acc])
    else
      {acc |> Enum.reverse() |> List.to_string(), [char | rest], pos}
    end
  end

  defp consume_until_newline(chars, start_pos) do
    consume_while(chars, start_pos, fn
      ?\n -> false
      _ -> true
    end)
  end
end
