{ config, options, lib, pkgs, ... }:
with lib;
let
  cfg = config.modules.web.browser.firefox;
  configDir = "${config.dotfiles.configDir}/firefox";
  inherit (pkgs.stdenv.targetPlatform) isLinux;
in
{
  options.modules.web.browser.firefox = with my; {
    enable = mkBoolOpt false;
    tridactyl = mkBoolOpt false;
  };

  config = mkIf cfg.enable (mkMerge [
    {
      env.BROWSER = "firefox";

      home = {
        programs.firefox = {
          enable = true;
          profiles = {
            default = {
              settings = {
                # I'll manage the updates thanks.
                "app.update.auto" = false;
                "app.update.service.enabled" = false;
                "app.update.download.promptMaxAttempts" = 0;
                "app.update.elevation.promptMaxAttempts" = 0;
                # HTTPs only.
                "dom.security.https_only_mode" = true;
                "dom.security.https_only_mode_ever_enabled" = true;
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
                "browser.compactmode.show" = true;
                # Hide warnings when playing with config.
                "browser.aboutConfig.showWarning" = false;
                # Plain new tabs.
                "browser.newtabpage.enabled" = false;
                # Smaller tab widths.
                "browser.tabs.tabMinWidth" = 50;
                # Search.
                "browser.urlbar.placeholderName" = "Kagi";
                "browser.urlbar.placeholderName.private" = "Kagi";
                "browser.search.defaultenginename" = "Kagi";
                "browser.search.selectedEngine" = "Kagi";
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
                "security.certerrors.mitm.auto_enable_enterprise_roots" = false;
                # Speed up scroll for Linux/Xorg.
                "mousewheel.min_line_scroll_amount" = 60;
              };
              userChrome = builtins.readFile "${configDir}/userChrome.css";
            };
          };
        };

        configFile = mkIf cfg.tridactyl {
          # Base16 colour schemes for Tridactyl.
          "tridactyl/themes" = {
            source =
              builtins.fetchGit "https://github.com/bezmi/base16-tridactyl.git";
            recursive = true;
          };
          "tridactyl/tridactylrc".text =
            let
              host = "${config.secrets.work_vcs_host}";
              path = "${config.secrets.work_vcs_path}";
              jira = "${config.secrets.work_jira}";
              sourcegraph = "${config.secrets.work_sourcegraph}";
            in
            builtins.readFile "${configDir}/tridactylrc" + ''
              " Set a custom colour theme.
              colourscheme ${config.modules.theme.tridactyl}

              " Search work VCS.
              set searchurls.w https://${host}/search?q=org%3A${path}+%s
              set searchurls.wsg https://${sourcegraph}/search?q=%s

              " Search work JIRA.
              set searchurls.j https://${jira}.atlassian.net/browse/%s
            '';
        };
      };
    }
    (if isLinux then {
      home = {
        defaultApplications = {
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

        # Wire up Tridactyl native for NixOS.
        file.".mozilla/native-messaging-hosts" = {
          source =
            "${pkgs.tridactyl-native}/lib/mozilla/native-messaging-hosts";
          recursive = true;
        };
      };
    } else {
      # Darwin.
      # Current $WORK forces use of a cask.
      # homebrew.casks = [ "firefox" ];
      # Expose my custom Darwin Firefox derivation to the environment and the
      # home-manager module.
      environment.systemPackages = [ pkgs.my.firefox ];
      home = {
        programs.firefox.package = pkgs.my.firefox;

        # Wire up Tridactyl native for macOS.
        # file."Library/Application Support/Mozilla/NativeMessagingHosts" = {
        #   source =
        #     "${pkgs.tridactyl-native}/lib/mozilla/native-messaging-hosts";
        #   recursive = true;
        # };
      };
    })
  ]);
}
