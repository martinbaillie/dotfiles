{ pkgs, ... }: {
  my = {
    packages = with pkgs; [ unstable.terraform vault awscli ];
    home.xdg.configFile."zsh/rc.d/rc.terraform.zsh".source =
      <config/terraform/rc.zsh>;
  };
}
