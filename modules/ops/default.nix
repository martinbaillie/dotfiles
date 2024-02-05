{ config, options, lib, pkgs, ... }:
with lib;
let cfg = config.modules.ops;
in
{
  options.modules.ops = { enable = my.mkBoolOpt false; };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      #open-policy-agent
      buildkite-cli
      buildkite-agent
      crane
      terraform
      unstable.terraform-ls
      unstable.yaml-language-server
      vault
    ];

    modules.shell.zsh.aliases = { tf = "terraform"; };
  };
}
