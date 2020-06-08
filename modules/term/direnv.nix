{ pkgs, ... }: {
  my = {
    packages = [ pkgs.direnv ];
    home.xdg.configFile."zsh/rc.d/rc.direnv.zsh".text =
      ''eval "$(direnv hook zsh)"'';
  };
}
