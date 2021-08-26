{ config, options, lib, pkgs, ... }:
with lib;
let cfg = config.modules.ops.aws;
in {
  options.modules.ops.aws = { enable = my.mkBoolOpt false; };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # FIXME: Waiting on an answer from AWS re. aarch64.
      # https://github.com/aws/session-manager-plugin/issues/9
      # ssm-session-manager-plugin
      nodePackages.cdktf-cli

      # Python issues on stable (aarch64).
      unstable.awscli2
      # Broken everywhere. Using homebrew for now.
      # unstable.aws-sam-cli (aarch64).
    ];
  };
}
