defmodule Mix.Tasks.Compile.Elm do
  @config_defaults [
    src_dir: "web",
    main_module: "Main.elm",
    compiler_arguments: ["--output", "elm.js"],
    destination_dir: "priv/static",
    assets_to_stage: ["elm.js"]
  ]

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
        [app: :my_app,
         version: "1.0.0",
         elixir: "~> 1.7",
         elm: [
           src_dir: "src",
           destination_dir: "public",
           compiler_arguments: ["--output", "main.js", "--debug"],
           assets_to_stage: ["index.html", "main.js", "styles/", "resources/"]
         ],
         deps: deps()]
      end
  """

  @shortdoc "Compiles Elm source files"

  @type step_result :: :ok | {:error, [String.t()]}

  use Mix.Task.Compiler

  @spec run([String.t()]) :: step_result
  def run(_args) do
    unless Mix.env() == :prod do
      Mix.shell().info("Compiling Elm assets")

      with :ok <- verify_elm_install(),
           {:ok, elm_config} <- project_elm_config(),
           :ok <- verify_source_dir(elm_config),
           :ok <- verify_main_elm_file(elm_config),
           :ok <- compile_elm_assets(elm_config),
           :ok <- ensure_staging_area(elm_config),
           :ok <- move_compiled_assets_to_staging_area(elm_config) do
        Mix.shell().info("Elm assets compiled and moved to #{elm_config[:destination_dir]}.")
        :ok
      else
        {:error, reason} ->
          {:error, [reason]}
      end
    end
  end

  @spec verify_elm_install :: step_result
  defp verify_elm_install do
    case System.find_executable("elm") do
      nil ->
        {:error, "\"elm\" not found in the path. An elm-lang installation is required."}

      _ ->
        :ok
    end
  end

  @spec project_elm_config :: step_result
  defp project_elm_config do
    case Mix.Project.config()[:elm] do
      nil ->
        {:ok, @config_defaults}

      config ->
        {:ok, merge_config(config)}
    end
  end

  @spec merge_config(Keyword.t()) :: step_result
  def merge_config(config) do
    Keyword.merge(config, @config_defaults, fn _key, supplied_value, default_value ->
      unless supplied_value == nil do
        supplied_value
      else
        default_value
      end
    end)
  end

  @spec verify_source_dir(Keyword.t()) :: step_result
  defp verify_source_dir(config) do
    if File.exists?(config[:src_dir]) do
      :ok
    else
      {:error, "Expected source dir: #{config[:src_dir]} not found."}
    end
  end

  @spec verify_main_elm_file(Keyword.t()) :: step_result
  defp verify_main_elm_file(config) do
    main_elm_module = Path.join(config[:src_dir], config[:main_module])

    if File.exists?(main_elm_module) do
      :ok
    else
      {:error, "Expected Elm source file: #{main_elm_module} not found."}
    end
  end

  @spec compile_elm_assets(Keyword.t()) :: step_result
  defp compile_elm_assets(config) do
    source_dir = config[:src_dir]
    main_elm_module = config[:main_module]

    exec = "elm"
    args = ["make"] ++ [main_elm_module] ++ config[:compiler_arguments]
    status = cmd(exec, args, source_dir, [])

    if status == 0 do
      :ok
    else
      {:error, "Could not compile with \"#{exec}\" (exit status: #{status})."}
    end
  end

  @spec cmd(String.t(), [String.t()], Path.t(), Keyword.t()) :: step_result
  defp cmd(exec, args, cwd, env) do
    opts = [
      cd: cwd,
      env: env
    ]

    {_, status} = System.cmd(exec, args, opts)

    status
  end

  @spec ensure_staging_area(Keyword.t()) :: step_result
  defp ensure_staging_area(config) do
    destination_dir = config[:destination_dir]

    case File.mkdir_p(destination_dir) do
      :ok ->
        :ok

      {:error, error_code} ->
        {:error, "Could not create #{config[:destination_dir]}. Posix error-code: #{error_code}."}
    end
  end

  @spec move_compiled_assets_to_staging_area(Keyword.t()) :: step_result
  defp move_compiled_assets_to_staging_area(config) do
    destination_area = config[:destination_dir]
    source_area = config[:src_dir]

    Enum.each(config[:assets_to_stage], fn filename ->
      source = Path.join(source_area, filename)

      case File.dir?(source) do
        true ->
          File.cp_r(source, Path.join(destination_area, filename))

        false ->
          File.cp(source, Path.join(destination_area, filename))
      end
    end)

    :ok
  end
end
