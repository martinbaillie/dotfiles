{ lib, pkgs, ... }:
with pkgs;
let
  inherit (lib) optionals optionalString mkMerge mkIf makeBinPath;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; })
    isLinux isDarwin;
  myEmacs = if isDarwin then
    my.Emacs
  else
    my.Emacs; # my.EmacsWayland (slow rendering on Sway...);

  myEmacsClient = writeShellScriptBin "emacs.bash" (''
    ${myEmacs}/bin/emacsclient --no-wait --eval \
      "(if (> (length (frame-list)) 0) 't)" 2> /dev/null | grep -q t
    if [[ "$?" -eq 1 ]]; then
      ${myEmacs}/bin/emacsclient \
        --quiet --create-frame --alternate-editor="" "$@"
    else
      ${myEmacs}/bin/emacsclient --quiet "$@"
    fi
  '' + optionalString isDarwin ''
    command -v osascript > /dev/null 2>&1 && \
        osascript -e 'tell application "Emacs" to activate' 2>/dev/null
    command -v osascript > /dev/null 2>&1 && \
        osascript -e 'tell application "System Events" to tell process "Emacs"
        set frontmost to true
        windows where title contains "Emacs"
        if result is not {} then perform action "AXRaise" of item 1 of result
    end tell' &> /dev/null || exit 0'');
in mkMerge [
  {
    my = {
      packages = [
        myEmacsClient
        ((emacsPackagesNgGen myEmacs).emacsWithPackages
          (epkgs: (with epkgs.melpaPackages; [ vterm emacsql emacsql-sqlite ])))

        # Emacs external dependencies.
        discount
        editorconfig-core-c
        emacs-pdf-tools
        languagetool
        pandoc
        zstd

        (hiPrio clang)
      ] ++ optionals isLinux [ wkhtmltopdf ];

      home.xdg.configFile = {
        "zsh/rc.d/rc.emacs.zsh".source = <config/emacs/rc.zsh>;
        "zsh/rc.d/env.emacs.zsh".source = <config/emacs/env.zsh>;
      };
    };

    fonts.fonts = [ emacs-all-the-icons-fonts ];
  }

  (mkIf isLinux {
    my = {
      home.xdg = {
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

        mimeApps.defaultApplications = {
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
    };
  })
]
