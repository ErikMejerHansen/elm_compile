defmodule ElmCompile.Mixfile do
  use Mix.Project

  @elixir_version "~> 1.7"
  @version "0.2.0"

  def project do
    [
      app: :elm_compile,
      version: @version,
      elixir: @elixir_version,
      compilers: Mix.compilers(),
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  def application do
    [applications: []]
  end

  defp deps do
    [{:ex_doc, "~> 0.19", only: :dev, runtime: false}]
  end

  defp description do
    """
    Simple elm compile hook-in for Mix projects
    """
  end

  defp package do
    [
      licenses: ["Apache 2.0"],
      maintainers: ["Erik Mejer Hansen"],
      links: %{"GitHub" => "https://github.com/ErikMejerHansen/elm_compile"}
    ]
  end
end
