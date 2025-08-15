defmodule Postcss.TokenizerTest do
  use ExUnit.Case, async: true

  alias Postcss.Tokenizer

  describe "basic tokenization" do
    test "tokenizes simple declaration" do
      css = "color: red"
      tokens = Tokenizer.tokenize(css)

      expected = [
        {:word, "color", 0, 4},
        {:colon, ":", 5},
        {:space, " ", 6},
        {:word, "red", 7, 9}
      ]

      assert tokens == expected
    end

    test "tokenizes rule with braces" do
      css = ".foo { color: red; }"
      tokens = Tokenizer.tokenize(css)

      expected = [
        {:word, ".foo", 0, 3},
        {:space, " ", 4},
        {:open_brace, "{", 5},
        {:space, " ", 6},
        {:word, "color", 7, 11},
        {:colon, ":", 12},
        {:space, " ", 13},
        {:word, "red", 14, 16},
        {:semicolon, ";", 17},
        {:space, " ", 18},
        {:close_brace, "}", 19}
      ]

      assert tokens == expected
    end

    test "handles strings" do
      css = ~s(content: "hello world")
      tokens = Tokenizer.tokenize(css)

      expected = [
        {:word, "content", 0, 6},
        {:colon, ":", 7},
        {:space, " ", 8},
        {:string, ~s("hello world"), 9, 21}
      ]

      assert tokens == expected
    end

    test "handles comments" do
      css = "/* comment */ color: red"
      tokens = Tokenizer.tokenize(css)

      expected = [
        {:comment, "/* comment */", 0, 12},
        {:space, " ", 13},
        {:word, "color", 14, 18},
        {:colon, ":", 19},
        {:space, " ", 20},
        {:word, "red", 21, 23}
      ]

      assert tokens == expected
    end

    test "handles at-rules" do
      css = "@media screen"
      tokens = Tokenizer.tokenize(css)

      expected = [
        {:at_word, "@media", 0, 5},
        {:space, " ", 6},
        {:word, "screen", 7, 12}
      ]

      assert tokens == expected
    end

    test "handles font declaration" do
      css = """
      @import url(\"https://www.example.com/fonts.css\");
      """

      tokens = Tokenizer.tokenize(css)

      expected = [
        {:at_word, "@import", 0, 6},
        {:space, " ", 7},
        {:word, "url", 8, 10},
        {:open_paren, "(", 11},
        {:string, ~s("https://www.example.com/fonts.css"), 12, 46},
        {:close_paren, ")", 47},
        {:semicolon, ";", 48},
        {:space, "\n", 49}
      ]

      assert tokens == expected
    end

    test "handles empty input" do
      assert Tokenizer.tokenize("") == []
    end

    test "handles whitespace only" do
      css = "   \n\t  "
      tokens = Tokenizer.tokenize(css)

      expected = [{:space, "   \n\t  ", 0}]
      assert tokens == expected
    end
  end

  describe "complex tokenization" do
    test "tokenizes nested rules" do
      css = ".foo { .bar { color: red; } }"
      tokens = Tokenizer.tokenize(css)

      # Should properly tokenize all braces and content
      open_braces = tokens |> Enum.count(&(elem(&1, 0) == :open_brace))
      close_braces = tokens |> Enum.count(&(elem(&1, 0) == :close_brace))

      assert open_braces == 2
      assert close_braces == 2
    end

    test "handles escaped characters in strings" do
      css = ~s(content: "hello \\"world\\"")
      tokens = Tokenizer.tokenize(css)

      string_token = Enum.find(tokens, &(elem(&1, 0) == :string))
      assert string_token == {:string, ~s("hello \\"world\\""), 9, 25}
    end
  end
end
