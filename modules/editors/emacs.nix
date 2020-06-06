{ lib, pkgs, ... }:
with pkgs;
let
  inherit (lib) optionals;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; })
    isLinux isDarwin;
in {
  my = {
    packages = let myEmacs = if isDarwin then my.Emacs else emacsGit;
    in [
      ((emacsPackagesNgGen myEmacs).emacsWithPackages (epkgs: [ epkgs.vterm ]))
      libvterm-neovim
      zstd
      editorconfig-core-c
      pandoc
      sqlite
    ] ++ optionals isLinux [ pinentry_emacs wkhtmltopdf ];

    home.xdg.configFile = {
      "zsh/rc.d/aliases.emacs.zsh".source = <config/emacs/aliases.zsh>;
      "zsh/rc.d/env.emacs.zsh".source = <config/emacs/env.zsh>;
    };
  };

  fonts.fonts = [ emacs-all-the-icons-fonts ];
}
