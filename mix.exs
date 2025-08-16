defmodule PostCSS.MixProject do
  use Mix.Project

  @version "0.1.2"
  @source_url "https://github.com/your-username/postcss_ex"

  def project do
    [
      app: :postcss,
      version: @version,
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      name: "PostCSS",
      source_url: @source_url
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    PostCSS for Elixir - A tool for transforming CSS.

    An Elixir implementation of the popular PostCSS JavaScript library, providing CSS parsing,
    AST manipulation, and stringification capabilities.
    """
  end

  defp package do
    [
      name: "postcss",
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @source_url,
        "Docs" => "https://hexdocs.pm/postcss"
      },
      maintainers: ["Your Name"]
    ]
  end

  defp docs do
    [
      main: "PostCSS",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: ["README.md", "LICENSE"]
    ]
  end
end
