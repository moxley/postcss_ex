defmodule Postcss.Rule do
  @moduledoc """
  Represents a CSS rule with a selector and declarations.

  Examples:
  - `.foo { color: red; }`
  - `#main, .sidebar { font-size: 12px; }`
  """

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
      # Follow PostCSS rule() method: this.block(node, this.rawValue(node, 'selector'))
      block(rule, rule.selector)
    end

    # Implements PostCSS block() method logic
    defp block(node, start) do
      alias Postcss.Raws

      # Get "between" (space before opening brace) - defaults to beforeOpen (" ")
      between = Map.get(node.raws || %{}, :between, Map.get(Raws.defaults(), :before_open))

      # Build the opening: "selector + between + {"
      opening = "#{start}#{between}{"

      # Handle body and after content
      {body_content, after_content} =
        if Enum.empty?(node.nodes) do
          # Empty rule: use emptyBody default
          {"", Map.get(node.raws || %{}, :after, Map.get(Raws.defaults(), :empty_body))}
        else
          # Has children: call body() and get after
          body = body(node)
          after_raw = Map.get(node.raws || %{}, :after, "\n")
          {body, after_raw}
        end

      # Build final result: opening + body + after + "}"
      "#{opening}#{body_content}#{after_content}}"
    end

    # Implements PostCSS body() method logic (same as Root)
    defp body(node) do
      alias Postcss.Raws

      if Enum.empty?(node.nodes) do
        ""
      else
        # Find last non-comment node for semicolon logic
        last_non_comment_index = find_last_non_comment_index(node.nodes)

        # Get semicolon setting for the container (default true for CSS formatting)
        container_semicolon = Map.get(node.raws || %{}, :semicolon, true)

        node.nodes
        |> Enum.with_index()
        |> Enum.map(fn {child, index} ->
          # Get "before" whitespace using PostCSS raw() logic
          before = raw(child, :before)

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
      raw_before =
        case Map.get(node.raws || %{}, :before) do
          nil ->
            # Apply PostCSS logic for different node types
            case node do
              %Postcss.Declaration{} -> Map.get(Raws.defaults(), :before_decl)
              %Postcss.Comment{} -> Map.get(Raws.defaults(), :before_comment)
              _ -> Map.get(Raws.defaults(), :before_rule)
            end

          value ->
            # Normalize inline formatting to block formatting for declarations
            if match?(%Postcss.Declaration{}, node) and is_binary(value) and
                 not String.contains?(value, "\n") do
              # Convert inline spacing (like " ") to proper block formatting
              Map.get(Raws.defaults(), :before_decl)
            else
              value
            end
        end

      # Apply PostCSS beforeAfter logic: add indentation if value contains newline
      # BUT only if it doesn't already have proper indentation
      if String.contains?(raw_before, "\n") do
        # Check if the value already has indentation after the newline
        lines = String.split(raw_before, "\n")
        last_line = List.last(lines) || ""

        # If the last line is empty or only whitespace, and we're at the default level,
        # add indentation. Otherwise, preserve the existing formatting.
        if last_line == "" or (String.trim(last_line) == "" and String.length(last_line) < 2) do
          indent = Map.get(Raws.defaults(), :indent)
          # For nodes inside a rule block, add 1 level of indentation (depth = 1)
          raw_before <> indent
        else
          # Already has indentation, preserve it
          raw_before
        end
      else
        raw_before
      end
    end
  end
end
