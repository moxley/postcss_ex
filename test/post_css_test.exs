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
  end
end
