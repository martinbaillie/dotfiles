{ config, pkgs, lib, ... }:
with import <home-manager/modules/lib/dag.nix> { inherit lib; }; {
  # My default desktop apps and settings across all macOS/Darwin installs.
  my = {
    home = {
      # Fix macOS Application links.
      home.activation = {
        copyApplications = let
          apps = pkgs.buildEnv {
            name = "home-manager-applications";
            paths = config.my.packages;
            pathsToLink = "/Applications";
          };
        in dagEntryAfter [ "writeBoundary" ] ''
          baseDir="$HOME/Applications/Home Manager Apps"
          if [ -d "$baseDir" ]; then
            rm -rf "$baseDir"
          fi
          mkdir -p "$baseDir"
          for appFile in ${apps}/Applications/*; do
            target="$baseDir/$(basename "$appFile")"
            $DRY_RUN_CMD cp ''${VERBOSE_ARG:+-v} -fHRL "$appFile" "$baseDir"
            $DRY_RUN_CMD chmod ''${VERBOSE_ARG:+-v} -R +w "$target"
          done
        '';
      };

      # Align common keybindings between Linux and Darwin.
      home.file."Library/KeyBindings/DefaultKeyBinding.dict".text = ''
        {
            "^\U007F" = deleteWordBackward:; // ctrl-delete
        }
      '';

      xdg = {
        # As always, remap capslock to ctrl (held)/escape (pressed).
        configFile."karabiner/karabiner.json".source =
          <config/karabiner/karabiner.json>;

        # Write any configured brews and casks to a Brewfile.
        configFile."homebrew/Brewfile" = {
          text = let
            brews = map (v: ''brew "${v}"'') config.my.brews;
            casks = map (v: ''cask "${v}"'') config.my.casks;
          in ''
            tap "homebrew/core"
            tap "homebrew/bundle"
            tap "homebrew/services"
            tap "homebrew/cask"
            tap "homebrew/cask-versions"

            ${lib.concatStringsSep "\n" brews}
            ${lib.concatStringsSep "\n" casks}
          '';
          onChange = "brew bundle || true";
        };
      };
    };
    env.HOMEBREW_BUNDLE_FILE = "$XDG_CONFIG_HOME/homebrew/Brewfile";

    packages = with pkgs; [ ];
    casks = [ "karabiner-elements" "spectacle" "flux" "cursorcerer" ];
  };

  # Fonts.
  fonts = {
    enableFontDir = true;
    fonts = with pkgs; [ iosevka ];
  };

  # My default desktop system settings across all macOS/Darwin installs.
  system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };

    defaults = {
      dock = {
        autohide = true;
        mru-spaces = false;
        orientation = "left";
        showhidden = true;
        tilesize = 32;
        expose-animation-duration = "0.0";
      };

      finder = {
        AppleShowAllExtensions = true;
        QuitMenuItem = true;
        FXEnableExtensionChangeWarning = false;
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };

      NSGlobalDomain = {
        AppleKeyboardUIMode = 3;
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 25;
        KeyRepeat = 1;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        PMPrintingExpandedStateForPrint2 = true;
        _HIHideMenuBar = true;
      };

      LaunchServices.LSQuarantine = false;
      loginwindow.DisableConsoleAccess = false;
    };
  };
}
