{ lib, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };

  my = {
    env.ZDOTDIR = "$XDG_CONFIG_HOME/zsh";
    env.ZSH_CACHE = "$XDG_CACHE_HOME/zsh";
    env.ZGEN_DIR = "$XDG_CACHE_HOME/zgen";
    env.ZGEN_SRC = builtins.fetchGit "https://github.com/tarjoilija/zgen";

    home.xdg.configFile."zsh" = {
      source = <config/zsh>;
      recursive = true;
    };
  };
}
