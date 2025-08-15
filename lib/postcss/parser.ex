defmodule Postcss.Parser do
  @moduledoc """
  CSS Parser for PostCSS.

  Converts tokens from the tokenizer into an Abstract Syntax Tree (AST).
  """

  alias Postcss.{Tokenizer, Root, Rule, Declaration, CssSyntaxError}

  @doc """
  Parses CSS string into a PostCSS AST.
  """
  def parse(css) when is_binary(css) do
    css
    |> Tokenizer.tokenize()
    |> parse_tokens()
  end

  defp parse_tokens(tokens) do
    tokens
    |> filter_meaningful_tokens()
    |> parse_root()
  end

  defp filter_meaningful_tokens(tokens) do
    # Keep spaces for selector parsing, remove only standalone spaces not between words
    tokens
  end

  defp parse_root(tokens) do
    {nodes, remaining} = parse_nodes(tokens, [])

    unless Enum.empty?(remaining) do
      raise CssSyntaxError.new("Unexpected tokens at end of input")
    end

    %Root{nodes: nodes}
  end

  defp parse_nodes([], acc), do: {Enum.reverse(acc), []}

  defp parse_nodes([{:close_brace, _} | _] = tokens, acc) do
    {Enum.reverse(acc), tokens}
  end

  defp parse_nodes([{:space, _, _} | rest], acc) do
    # Skip standalone spaces
    parse_nodes(rest, acc)
  end

  defp parse_nodes([{:space, _, _, _} | rest], acc) do
    # Skip standalone spaces
    parse_nodes(rest, acc)
  end

  defp parse_nodes(tokens, acc) do
    case parse_node(tokens) do
      {node, remaining} ->
        parse_nodes(remaining, [node | acc])

      :error ->
        raise CssSyntaxError.new("Failed to parse node")
    end
  end

  defp parse_node(tokens) do
    case tokens do
      # Simple declaration: word : value
      [{:word, prop, _, _} | rest] ->
        rest = skip_spaces(rest)

        case rest do
          [{:colon, _, _} | value_tokens] ->
            # This is a declaration
            case parse_declaration_value(value_tokens) do
              {value, important, remaining} ->
                decl = %Declaration{prop: prop, value: value, important: important}
                {decl, remaining}

              :error ->
                raise CssSyntaxError.new("Failed to parse declaration value")
            end

          _ ->
            # This might be a selector, collect all tokens until we find an open brace
            case collect_selector_tokens(tokens) do
              {[_ | _] = selector_tokens, [{:open_brace, _, _} | rule_rest]} ->
                selector = extract_selector_from_tokens(selector_tokens)
                {declarations, remaining} = parse_declarations(rule_rest, [])

                case remaining do
                  [{:close_brace, _, _} | rest_tokens] ->
                    rule = %Rule{selector: selector, nodes: declarations}
                    {rule, rest_tokens}

                  [] ->
                    raise CssSyntaxError.new("Unclosed rule: missing '}'")

                  _ ->
                    raise CssSyntaxError.new("Expected '}' after rule declarations")
                end

              {[_ | _] = tokens_found, _} ->
                [first_token | _] = tokens_found
                raise CssSyntaxError.new("Unexpected token: #{inspect(first_token)}")

              _ ->
                :error
            end
        end

      # Other tokens - try to parse as selector
      _ ->
        case collect_selector_tokens(tokens) do
          {[_ | _] = selector_tokens, [{:open_brace, _, _} | rule_rest]} ->
            selector = extract_selector_from_tokens(selector_tokens)
            {declarations, remaining} = parse_declarations(rule_rest, [])

            case remaining do
              [{:close_brace, _, _} | rest_tokens] ->
                rule = %Rule{selector: selector, nodes: declarations}
                {rule, rest_tokens}

              [] ->
                raise CssSyntaxError.new("Unclosed rule: missing '}'")

              _ ->
                raise CssSyntaxError.new("Expected '}' after rule declarations")
            end

          {[_ | _] = tokens_found, _} ->
            [first_token | _] = tokens_found
            raise CssSyntaxError.new("Unexpected token: #{inspect(first_token)}")

          _ ->
            :error
        end
    end
  end

  defp collect_selector_tokens(tokens) do
    collect_selector_tokens(tokens, [])
  end

  defp collect_selector_tokens([], acc), do: {Enum.reverse(acc), []}

  defp collect_selector_tokens([{:open_brace, _, _} | _] = tokens, acc),
    do: {Enum.reverse(acc), tokens}

  defp collect_selector_tokens([token | rest], acc),
    do: collect_selector_tokens(rest, [token | acc])

  defp extract_selector_from_tokens(tokens) do
    tokens
    |> Enum.map(fn
      {:word, value, _, _} -> value
      {:at_word, value, _, _} -> value
      {:space, value, _} -> value
      {:space, value, _, _} -> value
      {:comma, value, _} -> value
      {:colon, value, _} -> value
      {_, value, _} -> value
      {_, value, _, _} -> value
    end)
    |> Enum.join("")
    |> String.trim()
  end

  defp parse_declarations(tokens, acc) do
    case tokens do
      [{:close_brace, _, _} | _] ->
        {Enum.reverse(acc), tokens}

      [] ->
        {Enum.reverse(acc), []}

      [{:space, _, _} | rest] ->
        # Skip spaces in declarations
        parse_declarations(rest, acc)

      [{:space, _, _, _} | rest] ->
        # Skip spaces in declarations
        parse_declarations(rest, acc)

      _ ->
        case parse_declaration(tokens) do
          {decl, remaining} ->
            # Skip semicolon if present
            remaining = skip_semicolon(remaining)
            parse_declarations(remaining, [decl | acc])

          :error ->
            {Enum.reverse(acc), tokens}
        end
    end
  end

  defp parse_declaration([{:word, prop, _, _} | rest]) do
    # Skip spaces and look for colon
    rest = skip_spaces(rest)

    case rest do
      [{:colon, _, _} | value_tokens] ->
        case parse_declaration_value(value_tokens) do
          {value, important, remaining} ->
            decl = %Declaration{prop: prop, value: value, important: important}
            {decl, remaining}

          :error ->
            :error
        end

      _ ->
        :error
    end
  end

  defp parse_declaration(_), do: :error

  defp skip_spaces([{:space, _, _} | rest]), do: skip_spaces(rest)
  defp skip_spaces([{:space, _, _, _} | rest]), do: skip_spaces(rest)
  defp skip_spaces(tokens), do: tokens

  defp parse_declaration_value(tokens) do
    case collect_value_tokens(tokens, []) do
      {value_tokens, remaining} ->
        {value, important} = process_value_tokens(value_tokens)
        {value, important, remaining}

      :error ->
        :error
    end
  end

  defp collect_value_tokens([], acc), do: {Enum.reverse(acc), []}

  defp collect_value_tokens([{:semicolon, _, _} | _] = tokens, acc) do
    {Enum.reverse(acc), tokens}
  end

  defp collect_value_tokens([{:close_brace, _, _} | _] = tokens, acc) do
    {Enum.reverse(acc), tokens}
  end

  defp collect_value_tokens([token | rest], acc) do
    collect_value_tokens(rest, [token | acc])
  end

  defp process_value_tokens(tokens) do
    # Check for !important
    case Enum.reverse(tokens) do
      [{:word, "!important", _, _} | rest_tokens] ->
        value = extract_value_from_tokens(Enum.reverse(rest_tokens))
        {value, true}

      _ ->
        value = extract_value_from_tokens(tokens)
        {value, false}
    end
  end

  defp extract_value_from_tokens(tokens) do
    tokens
    |> Enum.map(fn
      {:word, value, _, _} -> value
      {:string, value, _, _} -> value
      {:colon, value, _} -> value
      {:at_word, value, _, _} -> value
      {_, value, _} -> value
      {_, value, _, _} -> value
    end)
    |> Enum.join("")
    |> String.trim()
  end

  defp skip_semicolon([{:semicolon, _, _} | rest]), do: skip_spaces(rest)
  defp skip_semicolon(tokens), do: skip_spaces(tokens)
end
