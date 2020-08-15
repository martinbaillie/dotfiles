{ lib, pkgs, config, ... }:
let
  inherit (lib) mkMerge mkIf;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; }) isLinux;
in mkMerge [
  {
    my = {
      env.BROWSER = "firefox";

      home.programs.firefox = {
        enable = true;
        package = with pkgs; if isLinux then firefox-wayland else my.Firefox;
        profiles = {
          default = {
            settings = {
              # I'll manage the updates thanks.
              "app.update.auto" = false;
              # Privacy and fingerprinting.
              "privacy.trackingprotection.enabled" = true;
              "privacy.trackingprotection.socialtracking.enabled" = true;
              "privacy.userContext.enabled" = true;
              # Disable Pocket.
              "extensions.pocket.enabled" = false;
              # Compact UI.
              "browser.uidensity" = 1;
              # Hide warnings when playing with config.
              "browser.aboutConfig.showWarning" = false;
              # Plain new tabs.
              "browser.newtabpage.enabled" = false;
              # Locale.
              "browser.search.region" = "AU";
              # Allow custom styling.
              "widget.content.allow-gtk-dark-theme" = true;
              "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
              "svg.context-properties.content.enabled" = true;
              # Don't save passwords or try to fill forms.
              "signon.rememberSignons" = false;
              "signon.autofillForms" = false;
            };
            userChrome = builtins.readFile <config/firefox/userChrome.css>;
          };
        };
      };
    };
  }
  (mkIf isLinux {
    my = {
      env.XDG_DESKTOP_DIR = "$HOME"; # prevent creation of ~/Desktop

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
    };
  })
]
