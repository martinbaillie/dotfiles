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
      home.xdg.mimeApps.defaultApplications = {
        "application/x-extension-htm" = [ "firefox.desktop" ];
        "application/x-extension-html" = [ "firefox.desktop" ];
        "application/x-extension-shtml" = [ "firefox.desktop" ];
        "application/x-extension-xht" = [ "firefox.desktop" ];
        "application/x-extension-xhtml" = [ "firefox.desktop" ];
        "application/xhtml+xml" = [ "firefox.desktop" ];
        "text/html" = [ "firefox.desktop" ];
        "x-scheme-handler/chrome" = [ "firefox.desktop" ];
        "x-scheme-handler/ftp" = [ "firefox.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
      };
      env.XDG_DESKTOP_DIR = "$HOME"; # prevent creation of ~/Desktop
    };
  })
]
