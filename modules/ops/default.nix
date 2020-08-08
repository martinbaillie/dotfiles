{ lib, pkgs, ... }:
let
  inherit (lib.systems.elaborate { system = builtins.currentSystem; }) isLinux;
in {
  my = {
    packages = with pkgs; [
      terraform
      terraform-lsp
      vault
      yaml-language-server
      dhall
      dhall-json
      haskellPackages.dhall-lsp-server
      (if isLinux then awscli else awscli2)
    ];
    home.xdg.configFile."zsh/rc.d/rc.terraform.zsh".source =
      <config/terraform/rc.zsh>;
  };
}
