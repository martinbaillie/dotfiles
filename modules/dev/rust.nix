{ config, lib, pkgs, ... }:
with lib;
let cfg = config.modules.dev.rust;
in
{
  options.modules.dev.rust = { enable = my.mkBoolOpt false; };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [ rustc cargo clippy rustfmt rust-analyzer rls ];

    env = {
      CARGO_HOME = "${config.my.xdg.dataHome}/cargo";
      PATH = [ "${config.my.xdg.dataHome}/cargo/bin" ];
    };
  };
}
