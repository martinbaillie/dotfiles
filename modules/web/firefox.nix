{ lib, pkgs, config, ... }:
let
  inherit (lib) mkMerge mkIf;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; })
    isLinux isDarwin;
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
              "app.update.service.enabled" = false;
              "app.update.download.promptMaxAttempts" = 0;
              "app.update.elevation.promptMaxAttempts" = 0;
              # Privacy and fingerprinting.
              "privacy.trackingprotection.enabled" = true;
              "privacy.trackingprotection.socialtracking.enabled" = true;
              "privacy.userContext.enabled" = true;
              # Disable Pocket.
              "extensions.pocket.enabled" = false;
              # Recently used order for tab cycles.
              "browser.ctrlTab.recentlyUsedOrder" = true;
              # Catch fat fingered quits.
              "browser.sessionstore.warnOnQuit" = true;
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
              # Tell Firefox not to trust fake Enterprise-injected certificates.
              "security.enterprise_roots.auto-enabled" = false;
              "security.enterprise_roots.enabled" = false;
            };
            userChrome = builtins.readFile <config/firefox/userChrome.css>;
          };
        };
      };

      # Tridactyl
      packages = [ pkgs.tridactyl-native ];

      home.xdg.configFile = {
        "tridactyl/tridactylrc".text = let
          # Use Emacs for long-form Firefox text area edits.
          #
          # On Linux, just create a new frame but with a name of 'Tridactyl' so I
          # can tell my tiling window manager du-jour to target and overlay it as
          # a central floating window above the Firefox window.
          #
          # On macOS, just use regular emacsclient but from a zsh context to
          # ensure correct envirionment and upon success, re-pop to Firefox.
          emacsclientTridactyl = pkgs.writeScriptBin "emacsclient-tridactyl"
            (if isLinux then ''
              emacsclient -q -F '((name . "Tridactyl"))' -c $@
            '' else ''
              #!${pkgs.zsh}/bin/zsh
              emacsclient -q $@ && osascript -e 'tell application "Firefox" to activate'
            '');
        in builtins.readFile <config/firefox/tridactylrc> + ''

          " Set a custom colour theme.
          colourscheme ${config.theme.tridactyl}

          " Emacs as my external editor.
          set editorcmd ${emacsclientTridactyl}/bin/emacsclient-tridactyl
        '';

        # Base16 colour schemes for Tridactyl.
        "tridactyl/themes" = {
          source =
            builtins.fetchGit "https://github.com/bezmi/base16-tridactyl.git";
          recursive = true;
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

      # REVIEW: home-manager support.
      home.home.file.".mozilla/native-messaging-hosts" = {
        source = "${pkgs.tridactyl-native}/lib/mozilla/native-messaging-hosts";
        recursive = true;
      };
    };
  })
  (mkIf isDarwin {
    # REVIEW: home-manager support.
    my.home.home.file."Library/Application Support/Mozilla/NativeMessagingHosts" =
      {
        source = "${pkgs.tridactyl-native}/lib/mozilla/native-messaging-hosts";
        recursive = true;
      };
  })
]
