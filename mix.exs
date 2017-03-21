defmodule ElmCompile.Mixfile do
  use Mix.Project

  def project do
    [app: :elm_compile,
     version: "0.1.0",
     compilers: Mix.compilers,
     elixir: "~> 1.4",
     description: description(),
     package: package(),
     deps: deps()
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: []]
  end

  defp deps do
    [ {:ex_doc, ">= 0.0.0", only: :dev} ]
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
