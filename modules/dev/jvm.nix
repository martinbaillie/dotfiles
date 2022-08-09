{ config, lib, pkgs, ... }:
with lib;
let cfg = config.modules.dev.jvm;
in
{
  options.modules.dev.jvm = {
    enable = my.mkBoolOpt false;
    bazel.enable = my.mkBoolOpt false;
  };

  config = mkMerge [
    ((mkIf cfg.enable) {
      user.packages = with pkgs; optionals cfg.bazel.enable
        [ bazel_5 buildifier ];
    })
    ((mkIf cfg.bazel.enable) {
      home.file.".bazelrc".text = ''
        # Stop confusing `gopls` workspaces.
        # build --symlink_prefix=_bazel_
        # test  --symlink_prefix=_bazel_

        # Also suppress the generation of the bazel-out symlink which always
        # appears no  matter what you set --symlink_prefix to.
        # build --experimental_no_product_name_out_symlink

        # LocalStack Pro API key passing.
        test --test_env=LOCALSTACK_API_KEY
      '';
    })
  ];
}
