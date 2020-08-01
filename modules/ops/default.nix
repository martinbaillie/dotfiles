{ pkgs, ... }: {
  my = {
    packages = with pkgs; [
      terraform
      terraform-lsp
      vault
      awscli
      yaml-language-server
    ];
    home.xdg.configFile."zsh/rc.d/rc.terraform.zsh".source =
      <config/terraform/rc.zsh>;
  };
}
