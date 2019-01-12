defmodule ElmCompileConfigTest do
  use ExUnit.Case
  alias Mix.Tasks.Compile.Elm

  test "Default configuration can be overridden" do
    override_src_dir = [elm: [src_dir: "not_web/"]]
    assert Elm.merge_config(override_src_dir)[:elm][:src_dir] == "not_web/"

    override_main_module = [elm: [main_module: "test.elm"]]
    assert Elm.merge_config(override_main_module)[:elm][:main_module] == "test.elm"

    override_destination_dir = [elm: [destination_dir: "web/static"]]
    assert Elm.merge_config(override_destination_dir)[:elm][:destination_dir] == "web/static"

    override_assets_to_stage = [elm: [assets_to_stage: ["css/", "javascript/", "fonts/"]]]

    assert Elm.merge_config(override_assets_to_stage)[:elm][:assets_to_stage] == [
             "css/",
             "javascript/",
             "fonts/"
           ]
  end
end
