{ lib, pkgs, ... }:
let
  inherit (lib) mkMerge mkIf;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; })
    isLinux isDarwin;
in mkMerge [
  { my.env.BROWSER = "firefox"; }
  (mkIf isDarwin { my.casks = [ "firefox-nightly" ]; })
  (mkIf isLinux {
    my = {
      packages = [ pkgs.firefox-wayland ];
      env.XDG_DESKTOP_DIR = "$HOME"; # prevent creation of ~/Desktop
    };
  })
]
