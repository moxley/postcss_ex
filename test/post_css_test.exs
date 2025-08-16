defmodule PostCSSTest do
  use ExUnit.Case, async: true
  doctest PostCSS

  alias PostCSS

  describe "parse/1" do
    test "parses simple CSS" do
      css = ".foo { color: red; }"
      root = PostCSS.parse(css)

      assert %PostCSS.Root{} = root
      assert length(root.nodes) == 1

      [rule] = root.nodes
      assert %PostCSS.Rule{} = rule
      assert rule.selector == ".foo"
    end
  end

  describe "stringify/1" do
    test "stringifies CSS AST" do
      root = PostCSS.parse(".foo { color: red; }")
      css_string = PostCSS.stringify(root)

      assert is_binary(css_string)
      assert String.contains?(css_string, ".foo")
      assert String.contains?(css_string, "color")
      assert String.contains?(css_string, "red")
    end

    test "handles something more complex" do
      css = """
      @import url("https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400..900;1,400..900&display=swap");

      :root {
        /* Primary accent color */
        --accent-color: #2630ed;
        --accent-color-lighter: #5e67f2;
        --bg-color: #eeeef7;
      }

      .SideCar .Navigation a:hover,
      .SideCar .Navigation a:active {
        color: var(--group-link-hover);
      }

      /* Marketing Area */

      .gf-area-marketing {
        font-family: "Playfair Display";
      }

      /* Members Area */

      .gf-area-members {
        background-color: var(--bg-color);
        font-family: "Playfair Display";
      }
      """

      root = PostCSS.parse(css)
      css_string = PostCSS.stringify(root)

      assert css_string == css
    end

    test "with media query" do
      css = """
      @media only screen and (max-width: 600px) {
        .app-container-icons {
          flex-direction: column;
          align-items: center;
          gap: 0em;
        }
      }

      .WelcomeBackPopUp {
        padding: 2rem;
        position: relative;
        background-color: white;
        box-shadow: 5px 5px 5px rgb(50 50 50 / 20%);
      }
      """

      root = PostCSS.parse(css)
      css_string = PostCSS.stringify(root)

      assert css_string == css
    end

    test "stringify comment with blank line after" do
      css = """
      .selector {
        color: red;
      }
      """

      root = PostCSS.parse(css)

      comment = %PostCSS.Comment{
        text: "comment",
        raws: %{left: " ", right: " "}
      }

      # To create spacing after the comment, set the 'before' raw on the following node
      [first_rule | rest] = root.nodes
      first_rule_with_spacing = %{first_rule | raws: Map.put(first_rule.raws, :before, "\n\n")}

      nodes = [comment, first_rule_with_spacing | rest]
      root = %PostCSS.Root{root | nodes: nodes}

      result_css = PostCSS.stringify(root)

      # Following JS PostCSS: spacing is controlled by the 'before' raw of the following node
      assert result_css == """
             /* comment */

             .selector {
               color: red;
             }
             """
    end

    test "font at rule" do
      css = """
      @font-face {
        font-family: "Avenir LT";
        src: url(https://mp1md-pub.s3.amazonaws.com/fonts/Avenir-LT-W01-85-Heavy.woff) format("woff");
      }
      """

      root = PostCSS.parse(css)

      # Should parse as a single @font-face at-rule
      assert length(root.nodes) == 1

      at_rule = List.first(root.nodes)
      assert %PostCSS.AtRule{} = at_rule
      assert at_rule.name == "font-face"
      assert at_rule.params == ""

      # Should contain 2 declarations (font-family and src)
      assert length(at_rule.nodes) == 2

      [font_family, src] = at_rule.nodes

      # Check font-family declaration
      assert %PostCSS.Declaration{} = font_family
      assert font_family.prop == "font-family"
      assert font_family.value == "\"Avenir LT\""
      assert font_family.important == false

      # Check src declaration
      assert %PostCSS.Declaration{} = src
      assert src.prop == "src"

      assert src.value ==
               "url(https://mp1md-pub.s3.amazonaws.com/fonts/Avenir-LT-W01-85-Heavy.woff) format(\"woff\")"

      assert src.important == false

      # Test round-trip: stringify should produce equivalent CSS
      result_css = PostCSS.stringify(root)

      # Parse the result and compare structure (allowing for formatting differences)
      reparsed_root = PostCSS.parse(result_css)
      assert length(reparsed_root.nodes) == 1

      reparsed_at_rule = List.first(reparsed_root.nodes)
      assert reparsed_at_rule.name == "font-face"
      assert length(reparsed_at_rule.nodes) == 2
    end
  end
end
