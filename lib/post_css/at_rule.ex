defmodule PostCSS.AtRule do
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
      # Follow PostCSS atrule() method logic
      name = "@#{at_rule.name}"
      params = at_rule.params || ""

      # Add space between name and params if params exist
      name_with_params =
        if params != "" do
          "#{name} #{params}"
        else
          name
        end

      if Enum.empty?(at_rule.nodes) do
        # Simple at-rule like @import url(...);
        "#{name_with_params};"
      else
        # Block at-rule like @media (...) { ... } - use same block logic as Rule
        block(at_rule, name_with_params)
      end
    end

    # Implements PostCSS block() method logic (same as Rule)
    defp block(node, start) do
      alias PostCSS.Raws

      # Get "between" (space before opening brace) - defaults to beforeOpen (" ")
      between = Map.get(node.raws || %{}, :between, Map.get(Raws.defaults(), :before_open))

      # Build the opening: "start + between + {"
      opening = "#{start}#{between}{"

      # Handle body and after content
      {body_content, after_content} =
        if Enum.empty?(node.nodes) do
          # Empty rule: use emptyBody default
          {"", Map.get(node.raws || %{}, :after, Map.get(Raws.defaults(), :empty_body))}
        else
          # Has children: call body() and get after
          body = body(node)

          # If no explicit after raw, infer closing brace indentation from at-rule's own before indentation
          after_raw =
            case Map.get(node.raws || %{}, :after) do
              nil ->
                # Infer indentation from the at-rule's own before value
                rule_before = Map.get(node.raws || %{}, :before, "")

                if String.contains?(rule_before, "\n") do
                  # Extract the indentation part (everything after the last newline)
                  lines = String.split(rule_before, "\n")
                  last_line = List.last(lines) || ""
                  # Use the same indentation for the closing brace
                  "\n#{last_line}"
                else
                  "\n"
                end

              explicit_after ->
                explicit_after
            end

          {body, after_raw}
        end

      # Build final result: opening + body + after + "}"
      "#{opening}#{body_content}#{after_content}}"
    end

    # Implements PostCSS body() method logic (same as Rule)
    defp body(node) do
      alias PostCSS.Raws

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
            if needs_semicolon and match?(%PostCSS.Declaration{}, child), do: ";", else: ""

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
      |> Enum.find(fn {node, _index} -> not match?(%PostCSS.Comment{}, node) end)
      |> case do
        {_node, index} -> index
        nil -> -1
      end
    end

    # Implements PostCSS raw() method logic for "before" values
    defp raw(node, :before) do
      alias PostCSS.Raws

      # Check if node has its own "before" raw
      raw_before =
        case Map.get(node.raws || %{}, :before) do
          nil ->
            # Apply PostCSS logic for different node types
            case node do
              %PostCSS.Declaration{} -> Map.get(Raws.defaults(), :before_decl)
              %PostCSS.Comment{} -> Map.get(Raws.defaults(), :before_comment)
              _ -> Map.get(Raws.defaults(), :before_rule)
            end

          value ->
            # Normalize inline formatting to block formatting for declarations
            if match?(%PostCSS.Declaration{}, node) and is_binary(value) and
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
