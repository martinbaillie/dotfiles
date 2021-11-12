{ config, options, lib, pkgs, ... }:
with lib;
let cfg = config.modules.ops;
in
{
  options.modules.ops = { enable = my.mkBoolOpt false; };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      ngrok
      open-policy-agent
      terraform
      terraform-lsp
      yaml-language-server

      # FIXME: Broken on aarch64.
      # vault
    ];

    modules.shell.zsh.aliases = { tf = "terraform"; };
  };
}
