{ config, options, lib, pkgs, ... }:
with lib;
let cfg = config.modules.ops;
in
{
  options.modules.ops = { enable = my.mkBoolOpt false; };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      #open-policy-agent
      terraform
      terraform-ls
      yaml-language-server
      vault
    ];

    modules.shell.zsh.aliases = { tf = "terraform"; };
  };
}
