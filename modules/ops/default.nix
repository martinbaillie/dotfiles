{ lib, pkgs, ... }: {
  my = {
    packages = with pkgs; [
      awscli2
      dhall
      dhall-json
      haskellPackages.dhall-lsp-server
      terraform
      terraform-lsp
      vault
      yaml-language-server
    ];
    home.xdg.configFile."zsh/rc.d/rc.terraform.zsh".source =
      <config/terraform/rc.zsh>;
  };
}
