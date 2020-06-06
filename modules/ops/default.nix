{ pkgs, ... }: {
  my = {
    packages = with pkgs; [ unstable.terraform vault awscli ];
    home.xdg.configFile."zsh/rc.d/aliases.terraform.zsh".source =
      <config/terraform/aliases.zsh>;
  };
}
