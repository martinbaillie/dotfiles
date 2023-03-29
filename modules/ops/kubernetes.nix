{ config, options, lib, pkgs, ... }:
with lib;
let cfg = config.modules.ops.kubernetes;
in
{
  options.modules.ops.kubernetes = { enable = my.mkBoolOpt false; };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      jsonnet-language-server
      krew
      kubectl
      kubectx
      kubernetes-helm
      kustomize
      k9s
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
