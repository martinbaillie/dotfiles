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

  valeStyles = [
    { name = "alex"; path = "${inputs.vale-alex}/alex"; }
    { name = "Google"; path = "${inputs.vale-Google}/Google"; }
    { name = "Microsoft"; path = "${inputs.vale-Microsoft}/Microsoft"; }
    { name = "Joblint"; path = "${inputs.vale-Joblint}/Joblint"; }
    { name = "proselint"; path = "${inputs.vale-proselint}/proselint"; }
    { name = "write-good"; path = "${inputs.vale-write-good}/write-good"; }
  ];

  # My Emacs and all its needs and wants.
  emacsWithDeps = with pkgs;
    [
      ((emacsPackagesFor cfg.package).emacsWithPackages (epkgs:
        with epkgs;
        # Use Nix to manage packages with non-trivial userspace dependencies.
        [
          emacsql
          emacsql-sqlite

          # FIXME: Currently building `epdinfo` on macOS like so:
          # ; nix-shell -p pkg-config poppler automake libtool libpng autoconf
          # ; autoreconf -i -f
          # ; ./autobuild -i /Users/mbaillie/.config/emacs/.local/straight/build-29.0.50/pdf-tools --os nixos
          pdf-tools

          org-pdftools
          vterm
        ]
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
      '' + optionalString config.targetSystem.isDarwin osascript))

      discount
      editorconfig-core-c
      languagetool
      # pandoc
      # (hiPrio clang)
      vale
    ]
    ++ optional config.targetSystem.isDarwin my.orgprotocolclient
    ++ optional config.targetSystem.isLinux wkhtmltopdf;
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

      home.file.".vale.ini".text =
        let
          stylesPath = pkgs.linkFarm "vale-styles" valeStyles;
          basedOnStyles = concatStringsSep ", "
            (zipAttrsWithNames [ "name" ] (_: v: v) valeStyles).name;
        in
        ''
          StylesPath = ${stylesPath}
          [*]
          BasedOnStyles = ${basedOnStyles}
        '';

      fonts.fonts = [ pkgs.emacs-all-the-icons-fonts ];
    }
    (mkIf config.targetSystem.isDarwin {
      environment.systemPackages = emacsWithDeps;

      user.packages =
        let
          # Pasting images to Emacs on macOS.
          pngpaste = with pkgs; stdenv.mkDerivation rec {
            src = fetchFromGitHub {
              owner = "jcsalterego";
              repo = "pngpaste";
              rev = "67c39829fedb97397b691617f10a68af75cf0867";
              sha256 = "089rqjk7khphs011hz3f355c7z6rjd4ydb4qfygmb4x54z2s7xms";
            };
            name = "pngpaste";
            buildInputs = [ pkgs.darwin.apple_sdk.frameworks.Cocoa ];
            installPhase = ''
              mkdir -p $out/bin
              cp pngpaste $out/bin/
            '';
          };
        in
        [ pngpaste ];
    })
    (mkIf config.targetSystem.isLinux {
      user.packages = emacsWithDeps ++ [
        (pkgs.makeDesktopItem {
          name = "org-protocol";
          exec = "${cfg.package}/bin/emacsclient %u";
          comment = "Org protocol";
          desktopName = "org-protocol";
          type = "Application";
          mimeTypes = ["x-scheme-handler/org-protocol"];
        })
      ];

      home = {
        dataFile."applications/emacsclient.desktop".text = ''
          [Desktop Entry]
          Categories=Development;
          TextEditor;
          Exec = emacs.bash - -no-wait %F
            GenericName=Text Editor
          Icon=emacs
          Keywords=Text;
          Editor;
          Name = Emacs
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
