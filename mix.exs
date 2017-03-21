defmodule ElmCompile.Mixfile do
  use Mix.Project

  def project do
    [app: :elm_compile,
     version: "0.1.0",
     compilers: Mix.compilers,
     elixir: "~> 1.3",
     description: description(),
     package: package()
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: []]
  end

  defp description do
    """
    Simple elm compile hook-in for Mix projects
    """
  end

  defp package do
    [
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/ErikMejerHansen/elm_compile"}
    ]
  end
end
