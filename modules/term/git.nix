{ pkgs, ... }: {
  my = {
    packages = with pkgs; [ git gitAndTools.hub gitAndTools.diff-so-fancy ];
    home.xdg.configFile = {
      "git/config".source = <config/git/config>;
      "git/ignore".source = <config/git/ignore>;
    };
  };
}
