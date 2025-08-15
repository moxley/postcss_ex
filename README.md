# PostCSS for Elixir

[![Hex.pm](https://img.shields.io/hexpm/v/postcss.svg)](https://hex.pm/packages/postcss)
[![Documentation](https://img.shields.io/badge/docs-hexdocs-blue.svg)](https://hexdocs.pm/postcss)

An Elixir implementation of the popular [PostCSS](https://postcss.org/) library, providing CSS parsing, AST manipulation, and stringification capabilities.

## Features

- **CSS Parsing**: Parse CSS strings into an Abstract Syntax Tree (AST)
- **AST Manipulation**: Create, modify, and traverse CSS nodes
- **CSS Generation**: Convert AST back to CSS strings
- **Node Types**: Support for rules, declarations, at-rules, comments, and more
- **Source Maps**: Preserve original formatting and whitespace

## Installation

Add `postcss` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:postcss, "~> 0.1.0"}
  ]
end
```

## Usage

### Basic Parsing and Stringification

```elixir
# Parse CSS string
css = """
.foo {
  color: red;
  margin: 10px;
}
"""

root = PostCSS.parse(css)

# Convert back to string
PostCSS.stringify(root)
```

### Creating Nodes Programmatically

```elixir
# Create a declaration
decl = PostCSS.decl("color", "blue")

# Create a rule with declarations
rule = PostCSS.rule(".my-class", [decl])

# Create a root with rules
root = PostCSS.root([rule])

# Generate CSS
PostCSS.stringify(root)
# => ".my-class {\n  color: blue;\n}"
```

### Working with At-Rules

```elixir
# Create an at-rule
media = PostCSS.at_rule("media", "screen and (max-width: 600px)", [
  PostCSS.rule(".responsive", [
    PostCSS.decl("display", "none")
  ])
])

root = PostCSS.root([media])
PostCSS.stringify(root)
```

### Adding Comments

```elixir
comment = PostCSS.comment("This is a comment")
rule = PostCSS.rule(".foo", [comment, PostCSS.decl("color", "red")])
```

## API Documentation

The main API consists of:

- `PostCSS.parse/1` - Parse CSS string into AST
- `PostCSS.stringify/1` - Convert AST to CSS string
- `PostCSS.decl/2` and `PostCSS.decl/3` - Create declaration nodes
- `PostCSS.rule/1` and `PostCSS.rule/2` - Create rule nodes
- `PostCSS.root/0` and `PostCSS.root/1` - Create root nodes
- `PostCSS.at_rule/1`, `PostCSS.at_rule/2`, and `PostCSS.at_rule/3` - Create at-rule nodes
- `PostCSS.comment/1` - Create comment nodes

## Node Types

The library supports all major CSS node types:

- **Root**: The top-level container for all CSS nodes
- **Rule**: CSS rules with selectors and declarations (e.g., `.foo { color: red; }`)
- **Declaration**: CSS property-value pairs (e.g., `color: red`)
- **AtRule**: At-rules like `@media`, `@import`, `@keyframes`
- **Comment**: CSS comments (e.g., `/* comment */`)

## Development

```bash
# Install dependencies
mix deps.get

# Run tests
mix test

# Generate documentation
mix docs

# Check formatting
mix format --check-formatted
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -am 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by the original [PostCSS](https://postcss.org/) JavaScript library
- Built with [Elixir](https://elixir-lang.org/)
