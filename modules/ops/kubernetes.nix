{ config, options, lib, pkgs, ... }:
with lib;
let cfg = config.modules.ops.kubernetes;
in
{
  options.modules.ops.kubernetes = { enable = my.mkBoolOpt false; };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      krew
      kubectl
      kubectx
      kubernetes-helm
      kustomize
      stern
    ];

    modules.shell.zsh.aliases = {
      kc = "kubectl";
      kcc = "kubectx";
      kcn = "kubens";
    };

    env.PATH = [ "$HOME/.krew/bin" ];
  };
}
