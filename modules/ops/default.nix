{ pkgs, ... }: {
  my = {
    packages = with pkgs; [
      unstable.terraform
      unstable.terraform-lsp
      vault
      awscli
      unstable.yaml-language-server
    ];
    home.xdg.configFile."zsh/rc.d/rc.terraform.zsh".source =
      <config/terraform/rc.zsh>;
  };
}
