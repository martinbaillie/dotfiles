{ config, lib, pkgs, inputs, ... }:
with lib;
let
  cfg = config.modules.desktop;
  mkSudoTouchIdAuthScript = isEnabled:
    let
      file = "/etc/pam.d/sudo";
      option = "modules.desktop.sudoTouchID";
    in
    ''
      ${if isEnabled then ''
        echo >&2 "enabling sudo touch ID..."
        # Enable sudo Touch ID authentication, if not already enabled
        if ! grep 'pam_tid.so' ${file} > /dev/null; then
          chflags nouchg ${file}
          sed -i "" '2i\
        auth       sufficient     pam_tid.so # nix-darwin: ${option}
          ' ${file}
        fi
        chflags uchg ${file}
      '' else ''
        echo >&2 "disabling sudo touch ID..."
        # Disable sudo Touch ID authentication, if added by nix-darwin
        chflags nouchg ${file}
        if grep '${option}' ${file} > /dev/null; then
          sed -i "" '/${option}/d' ${file}
        fi
      ''}
    '';
  inherit (inputs.home-manager.lib.hm) dag;
  inherit (pkgs.stdenv.targetPlatform) isDarwin;
in
{
  options.modules.desktop = {
    sudoTouchID = mkOption {
      type = types.bool;
      description = ''
        Enable sudo touch ID (Darwin).
      '';
      default = false;
    };
  };

  config = mkIf cfg.enable (optionalAttrs isDarwin
    {
      # macOS Apps that aren't in nixpkgs.
      homebrew.casks = [
        "cursorcerer" # Hide pointer when typing.
        "flux" # Still better than macOS NightShift.
        "font-iosevka" # Emacs font.
        "font-iosevka-aile" # Emacs font.
        "font-iosevka-etoile" # Emacs font.
        "karabiner-elements" # CapsLock as CTRL when held, ESC when tapped.
        # TODO: Use of secure enclave.
        # "secretive"
      ];

      home = {
        #activation = {
        #        aliasApplications =
        #          let
        #            apps = pkgs.buildEnv {
        #              name = "nix-managed-applications";
        #              paths = config.user.packages ++ config.environment.systemPackages;
        #              pathsToLink = "/Applications";
        #            };
        #          in
        #          dag.entryAfter [ "writeBoundary" ] ''
        #            find ${apps}/Applications/ -maxdepth 1 -type l | while read f; do
        #              src="$(/usr/bin/stat -f%Y $f)"
        #              dest="/Applications/$(basename $src .app)"
        #              [ -f "$dest" ] && rm $dest
        #              sleep 2 # Weird sync issue.
        #              /usr/bin/osascript -e "tell app \"Finder\" to \
        #                      make new alias file at POSIX file \"/Applications\" to \
        #                      POSIX file \"$src\""
        #            done
        #          '';
        #      };

        # Align common keybindings between Linux and Darwin.
        # TODO: Add more Emacs bindings.
        # TODO: Does this trick even work anymore?
        file."Library/KeyBindings/DefaultKeyBinding.dict".text = ''
          {
              "^\U007F" = deleteWordBackward:; // ctrl-delete
          }
        '';

        # As always, remap capslock to ctrl (held)/escape (pressed).
        configFile."karabiner/karabiner.json".source =
          "${config.dotfiles.configDir}/karabiner/karabiner.json";
      };

      # Fonts.
      fonts = {
        fontDir.enable = true;
        fonts = with pkgs; [
          # FIXME: doesn't build on aarch64 hence Cask above for now.
          # iosevka
        ];
      };

      # My default desktop system settings across all macOS/Darwin installs.
      system = {
        keyboard = {
          enableKeyMapping = true;
          remapCapsLockToControl = true;
        };

        defaults = {
          SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;

          dock = {
            autohide = true;
            expose-animation-duration = 0.0;
            minimize-to-application = true;
            mru-spaces = false;
            orientation = "left";
            show-recents = false;
            showhidden = true;
            tilesize = 32;
          };

          finder = {
            AppleShowAllExtensions = true;
            QuitMenuItem = true;
            FXEnableExtensionChangeWarning = false;
            _FXShowPosixPathInTitle = true;
          };

          trackpad = {
            Clicking = true;
            TrackpadThreeFingerDrag = true;
          };

          NSGlobalDomain = {
            AppleKeyboardUIMode = 3;
            ApplePressAndHoldEnabled = false;
            InitialKeyRepeat = 20;
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

        activationScripts.extraActivation.text = ''
          ${mkSudoTouchIdAuthScript cfg.sudoTouchID}
        '';
      };
    }
  );
}
