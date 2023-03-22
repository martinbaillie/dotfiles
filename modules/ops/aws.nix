{ config, options, lib, pkgs, ... }:
with lib;
let
  cfg = config.modules.ops.aws;
in
{
  options.modules.ops.aws = { enable = my.mkBoolOpt false; };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      awscli2
      (mkIf config.modules.services.docker.enable amazon-ecr-credential-helper)
    ];

    # Why not follow standard zsh completion? AWS always have to be different.
    # Sigh.
    modules.shell.zsh.rc =
      ". ${pkgs.awscli2}/share/zsh/site-functions/aws_zsh_completer.sh";
  };
}
