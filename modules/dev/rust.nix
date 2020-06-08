{ pkgs, ... }: {
  my = {
    home.xdg.configFile = {
      "zsh/rc.d/env.rust.zsh".source = <config/rust/env.zsh>;
    };
    packages = with pkgs;
      [
        (pkgs.latest.rustChannels.nightly.rust.override {
          extensions =
            [ "rust-src" "rls-preview" "rust-analysis" "rustfmt-preview" ];
        })
      ];
  };
}
