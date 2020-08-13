{ lib, pkgs, ... }:
let
  inherit (lib) mkMerge mkIf;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; })
    isLinux isDarwin;
  userChrome = ''
    #TabsToolbar {
        visibility: collapse;
    }
    #titlebar {
        visibility: collapse;
    }
    #sidebar-header {
        visibility: collapse;
    }

    /*** BEGIN Firefox 77 (June 2, 2020) Override URL bar enlargement ***/
    /***  https://support.mozilla.org/en-US/questions/1290682         ***/
    /* Compute new position, width, and padding */
    #urlbar[breakout][breakout-extend] {
      top: 5px !important;
      left: 0px !important;
      width: 100% !important;
      padding: 0px !important;
    }
    /* for alternate Density settings */
    [uidensity="compact"] #urlbar[breakout][breakout-extend] {
      top: 3px !important;
    }
    [uidensity="touch"] #urlbar[breakout][breakout-extend] {
      top: 4px !important;
    }
    /* Prevent shift of URL bar contents */
    #urlbar[breakout][breakout-extend] > #urlbar-input-container {
      height: var(--urlbar-height) !important;
      padding: 0 !important;
    }
    /* Do not animate */
    #urlbar[breakout][breakout-extend] > #urlbar-background {
      animation: none !important;;
    }
    /* Remove shadows */
    #urlbar[breakout][breakout-extend] > #urlbar-background {
      box-shadow: none !important;
    }
    /*** END Firefox 77 (June 2, 2020) Override URL bar enlargement ***/
  '';
  settings = { "toolkit.legacyUserProfileCustomizations.stylesheets" = true; };
in mkMerge [
  { my.env.BROWSER = "firefox"; }
  (mkIf isDarwin { my.casks = [ "firefox-nightly" ]; })
  (mkIf isLinux {
    my = {
      home.programs.firefox = {
        enable = true;
        package = pkgs.firefox-wayland;
        profiles = {
          default = {
            id = 0;
            settings = settings;
            userChrome = userChrome;
          };
        };
      };

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
