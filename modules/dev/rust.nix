{ pkgs, ... }: {
  my = {
    packages = with pkgs; [ rustup ];
    home.xdg.configFile = {
      "zsh/rc.d/env.rust.zsh".source = <config/rust/env.zsh>;
    };
  };
}
