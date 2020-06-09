{ pkgs, ... }: {
  my = {
    home.xdg.configFile = {
      "zsh/rc.d/env.rust.zsh".source = <config/rust/env.zsh>;
    };
    packages = with pkgs;
      let
        rustChannel = pkgs.rustChannelOf {
          date = "2020-06-08";
          channel = "nightly";
        };

        rust = rustChannel.rust.override {
          extensions = [
            "clippy-preview"
            "rust-analysis"
            "rls-preview"
            "rustfmt-preview"
          ];
        };
      in [ rust ];
  };
}
