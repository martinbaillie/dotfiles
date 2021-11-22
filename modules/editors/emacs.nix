{ config, lib, pkgs, inputs, ... }:
with lib;
let
  cfg = config.modules.editors.emacs;
  configDir = "${config.dotfiles.configDir}/emacs";

  # Darwin specific run-or-raise style script.
  osascript = ''
    command -v osascript > /dev/null 2>&1 && \
        osascript -e 'tell application "Emacs" to activate' 2>/dev/null
    command -v osascript > /dev/null 2>&1 && \
        osascript -e 'tell application "System Events" to tell process "Emacs"
        set frontmost to true
        windows where title contains "Emacs"
        if result is not {} then perform action "AXRaise" of item 1 of result
    end tell' &> /dev/null || exit 0'';

  # My Emacs and all its needs and wants.
  emacsWithDeps = with pkgs;
    [
      ((emacsPackagesNgGen cfg.package).emacsWithPackages (epkgs:
        with epkgs;
        # Use Nix to manage packages with non-trivial userspace dependencies.
        [ emacsql emacsql-sqlite pdf-tools org-pdftools vterm ]
        ++ optional (config.modules.desktop.wm == "exwm") exwm))

      # Use my own bespoke wrapper for `emacsclient`.
      (writeShellScriptBin "emacs.bash" (''
        ${cfg.package}/bin/emacsclient --no-wait --eval \
          "(if (> (length (frame-list)) 0) 't)" 2> /dev/null | grep -q t
        if [[ "$?" -eq 1 ]]; then
          ${cfg.package}/bin/emacsclient \
            --quiet --create-frame --alternate-editor="" "$@"
        else
          ${cfg.package}/bin/emacsclient --quiet "$@"
        fi
      '' + optionalString config.currentSystem.isDarwin osascript))

      discount
      editorconfig-core-c
      languagetool
      # pandoc
      # (hiPrio clang)
    ]
    ++ optional config.currentSystem.isDarwin my.orgprotocolclient
    ++ optional config.currentSystem.isLinux wkhtmltopdf;
in
{
  options.modules.editors.emacs = {
    enable = my.mkBoolOpt false;
    package = mkOption {
      type = types.package;
      default = pkgs.emacs;
      description = ''
        Emacs derivation to use.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      nixpkgs.overlays = [ inputs.emacs-overlay.overlay ];

      env.PATH = [ "$XDG_CONFIG_HOME/emacs/bin" ];

      home.configFile."zsh/rc.d/rc.emacs.zsh".source = "${configDir}/rc.zsh";

      fonts.fonts = [ pkgs.emacs-all-the-icons-fonts ];
    }
    (mkIf config.currentSystem.isDarwin {
      environment.systemPackages = emacsWithDeps;
    })
    (mkIf config.currentSystem.isLinux {
      user.packages = [
        emacsWithDeps

        (pkgs.makeDesktopItem {
          name = "org-protocol";
          exec = "${cfg.package}/bin/emacsclient %u";
          comment = "Org protocol";
          desktopName = "org-protocol";
          type = "Application";
          mimeType = "x-scheme-handler/org-protocol";
        })
      ];

      home = {
        dataFile."applications/emacsclient.desktop".text = ''
          [Desktop Entry]
          Categories=Development;TextEditor;
          Exec=emacs.bash --no-wait %F
          GenericName=Text Editor
          Icon=emacs
          Keywords=Text;Editor;
          Name=Emacs
          StartupWMClass=Emacs
          Terminal=false
          Type=Application
        '';

        defaultApplications = {
          # Prefer to use Emacs for file and directory operations.
          "application/octet-stream" = "emacsclient.desktop";
          "application/pdf" = "emacsclient.desktop";
          "application/x-directory" = "emacsclient.desktop";
          "application/x-ruby" = "emacsclient.desktop";
          "application/x-shellscript" = "emacsclient.desktop";
          "image/jpeg" = "emacsclient.desktop";
          "image/png" = "emacsclient.desktop";
          "image/vnd.djvu" = "emacsclient.desktop";
          "inode/directory" = "emacsclient.desktop";
          "inode/mount-point" = "emacsclient.desktop";
          "inode/x-empty" = "emacsclient.desktop";
          "text/plain" = "emacsclient.desktop";
          "text/rhtml" = "emacsclient.desktop";
          "text/x-c" = "emacsclient.desktop";
          "text/x-c++" = "emacsclient.desktop";
          "text/x-c++hdr" = "emacsclient.desktop";
          "text/x-chdr" = "emacsclient.desktop";
          "text/x-c++src" = "emacsclient.desktop";
          "text/x-csrc" = "emacsclient.desktop";
          "text/x-java" = "emacsclient.desktop";
          "text/x-makefile" = "emacsclient.desktop";
          "text/x-markdown" = "emacsclient.desktop";
          "text/x-moc" = "emacsclient.desktop";
          "text/x-pascal" = "emacsclient.desktop";
          "text/x-python" = "emacsclient.desktop";
          "text/x-readme" = "emacsclient.desktop";
          "text/x-ruby" = "emacsclient.desktop";
          "text/x-tcl" = "emacsclient.desktop";
          "text/x-tex" = "emacsclient.desktop";
        };
      };
    })
  ]);
}
