{ lib, pkgs, ... }: {
  my = {
    packages = with pkgs; [
      awscli2
      open-policy-agent
      ssm-session-manager-plugin
      terraform
      terraform-lsp
      vault
      yaml-language-server
    ];
    home.xdg.configFile."zsh/rc.d/rc.terraform.zsh".source =
      <config/terraform/rc.zsh>;
  };
}
