{ config, lib, pkgs, ... }:
with lib;
let cfg = config.modules.dev.jvm;
in
{
  options.modules.dev.jvm = {
    enable = my.mkBoolOpt false;
    bazel.enable = my.mkBoolOpt false;
  };

  config = mkIf
    (
      cfg.enable
      ||
      # I'm not using the JVM for anything else at the moment.
      cfg.bazel.enable
    )
    {
      user.packages = optional cfg.bazel.enable pkgs.bazel_4;
    };
}
