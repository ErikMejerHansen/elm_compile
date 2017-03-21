# ElmCompile

Simple elm compile hook-in for Mix projects

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

Add `elm_compile` to your list of dependencies in `mix.exs`:

    elixir
    def deps do
      [{:elm_compile, "~> 0.1.0", only: :dev}]
    end

You do not need to add it to your list of applications to start.

## Usage
Add `:elm` to your list of `compilers` in your project setup in `mix.exs`:

    elixir
    def project do
      [app: :your_app,
       version: "0.1.0",
       compilers: Mix.compilers ++ [:elm],
       elixir: "~> 1.3"]
    end

For configuration options please see `mix help compile.elm`
