{ config, options, lib, pkgs, ... }:
with lib;
let
  cfg = config.modules.ops.aws;
  awscli2 = pkgs.unstable.awscli2; # Python issues on stable (aarch64).
in {
  options.modules.ops.aws = { enable = my.mkBoolOpt false; };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      awscli2

      # FIXME: Waiting on an answer from AWS re. aarch64.
      # https://github.com/aws/session-manager-plugin/issues/9
      # ssm-session-manager-plugin
      nodePackages.cdktf-cli

      # Broken everywhere. Using homebrew for now.
      # unstable.aws-sam-cli (aarch64).
    ];

    # Why not follow standard zsh completion? AWS always have to be different.
    # Sigh.
    modules.shell.zsh.rc =
      "source ${awscli2}/share/zsh/site-functions/aws_zsh_completer.sh";
  };
}
