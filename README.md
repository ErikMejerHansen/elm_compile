# ElmCompile

Simple elm compile hook-in for Mix projects.

## Installation

Add `elm_compile` to your list of dependencies in `mix.exs`:

``` elixir
def deps do
  [{:elm_compile, "~> 0.2.0", only: :dev}]
end
```

## Usage

Add `:elm` to your list of `compilers` in your project setup in `mix.exs`:

``` elixir
def project do
  [app: :my_app,
   version: "1.0.0",
   elixir: "~> 1.7",
   compilers: Mix.compilers ++ [:elm]
   ]
end
```

For configuration options please see `mix help compile.elm`.
