defmodule Mix.Tasks.Compile.Elm do
  use Mix.Task

  @config_defaults [
    src_dir: "web/",
    main_module: "Main.elm",
    compiler_arguments: ["--output", "main.js"],
    destination_dir: "priv/static",
    assets_to_stage: ["index.html", "main.js", "style/", "resources/"]
  ]

  @shortdoc "Performs compilation and staging of Elm assets"
  @moduledoc """
  Performs compilation and staging of Elm assets.
  Requires an elm-lang installation, see: https://guide.elm-lang.org/install.html

  The elm compiler task accepts the following options:
  - `src_dir`: Location of the Elm assets to be compiled. Default: `#{@config_defaults[:src_dir]}`

  - `main_module`: The name of the main Elm module. Default: `#{@config_defaults[:main_module]}`

  - `compiler_arguments`: Arguments passed to the Elm compiler. Default: `#{@config_defaults[:compiler_arguments]}`

  - `destination_dir`: Location where the compiled Elm assets will be placed. Default: `#{@config_defaults[:destination_dir]}`

  - `assets_to_stage`: List of files and dirs to move to the `destination_dir` after the elm compiler finishes. Default: `[#{Enum.join(@config_defaults[:assets_to_stage], ", ")}]`

  ## Example:
      def project do
        [app: :elm_compile,
         version: "0.1.0",
         elixir: "~> 1.3",
         elm: [
           src_dir: "web/",
           destination_dir: "priv/static/"
         ],
         deps: deps()]
      end

  """

  def run(_args) do
    unless Mix.env == :prod do
      Mix.shell.info "Compiling Elm assets"
      with :ok <- verify_elm_install(),
           {:ok, elm_config} <- project_elm_config(),
             :ok <- verify_source_dir(elm_config),
             :ok <- verify_main_elm_file(elm_config),
             :ok <- compile_elm_assets(elm_config),
             :ok <- ensure_staging_area(elm_config),
             :ok <- move_compiled_assets_to_staging_area(elm_config)
        do
        Mix.shell.info ~s{Elm assets compiled and moved to #{elm_config[:destination_dir]}.\n}
        else
          {:error, reason} ->
            Mix.raise(reason)
      end
    end
  end

  defp project_elm_config do
    case Mix.Project.config[:elm] do
      nil ->
        {:ok, @config_defaults}
      config ->
        {:ok, merge_config(config)}
      end
  end

  defp verify_elm_install do
    System.find_executable("elm") || Mix.raise(~s{"elm" not found in the path. An elm-lang installation is required, see: https://guide.elm-lang.org/install.html.\n})
    :ok
  end



  def merge_config(config) do

    Keyword.merge(config, @config_defaults, fn(_key, supplied_value, default_value) ->
      unless is_nil(supplied_value) do supplied_value else default_value end
    end)

  end

  defp verify_source_dir(config) do

    case  File.exists?(config[:src_dir]) do
      true ->
        :ok
      false ->
        {:error, ~s{Expected source dir: #{config[:src_dir]} not found.\n}}
    end
  end

  defp verify_main_elm_file(config) do
    main_elm_module = config[:src_dir] <> "/" <>config[:main_module]

    case  File.exists?(main_elm_module) do
      true ->
        :ok
      false ->
        {:error, ~s{Expected Elm source file: #{main_elm_module} not found.\n}}
    end
  end

  defp compile_elm_assets(config) do
    source_dir = config[:src_dir]
    main_elm_module = config[:main_module]


    exec = "elm-make"
    args = [main_elm_module] ++ config[:compiler_arguments] ++ ["--yes"]

    Mix.shell.info "----- Elm-make output start: -----"
    status = cmd(exec, args, source_dir, [])
    Mix.shell.info "----- Elm-make output end: -----"

    case status do
      0 -> :ok
      _ -> raise_build_error(exec, status)
    end
  end

  defp raise_build_error(exec, exit_status) do
   Mix.raise(~s{Could not compile with "#{exec}" (exit status: #{exit_status}). It's propably a sytax error in your elm code. If so the out-put from "elm-make" should be displayed above.\n})
  end



  defp cmd(exec, args, cwd, env) do
    opts = [
      into: IO.stream(:stdio, :line),
      stderr_to_stdout: true,
      cd: cwd,
      env: env
    ]
    {_, status} = System.cmd(exec, args, opts)

    status
  end

  defp ensure_staging_area(config) do
    destination_dir = config[:destination_dir]
    case File.mkdir_p(destination_dir) do
      :ok -> :ok
      {:error, error_code} ->
        {:error, ~s{Could not create #{config[:destination_dir]}. Posix error-code: #{error_code} .\n}}
    end
  end

  defp move_compiled_assets_to_staging_area(config) do
    destination_area = config[:destination_dir]
    source_area = config[:src_dir]

    Enum.each(config[:assets_to_stage], fn file ->
      source = source_area <> file
      case File.dir?(source) do
        true ->
          File.cp_r!(source, destination_area <> "/" <> file)
        false ->
          File.cp(source, destination_area <> "/" <> file)
      end

    end)

    :ok
  end

end
