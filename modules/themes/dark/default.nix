{ lib, pkgs, ... }:
with builtins;
let
  inherit (lib) mkMerge mkIf;
  inherit (lib.systems.elaborate { system = currentSystem; }) isLinux;
  root = toPath ../../../.;
in {
  imports = [ ../. ];

  theme = mkMerge [
    {
      wallpaper = ./dj_nobu_dark.jpg;
      colours = import ./doom_dracula.nix;
      tridactyl = "base16-dracula";
    }

    (mkIf isLinux {
      icons = "${pkgs.paper-icon-theme}/share/icons/Paper-Mono-Dark";
    })
  ];

  my = mkMerge [
    {
      home.xdg.configFile."bat/config".text = ''--theme="Dracula"'';

      # Piggyback wallpaper change trigger to perform imperative theme updates.
      home.xdg.configFile."wallpaper".onChange = "make -B -C ${root} dark";
    }

    (mkIf isLinux {
      env.GTK_THEME = "Arc-Darker";
      packages = with pkgs; [
        arc-theme
        arc-icon-theme
        paper-gtk-theme
        paper-icon-theme
      ];
      home.xdg.configFile = {
        # GTK
        "gtk-3.0/settings.ini".text = ''
          [Settings]
          gtk-theme-name=Arc-Darker
          gtk-icon-theme-name=Arc
          gtk-fallback-icon-theme=gnome
          gtk-application-prefer-dark-theme=true
          gtk-xft-hinting=1
          gtk-xft-hintstyle=hintfull
          gtk-xft-rgba=none
        '';
        # GTK2 global theme (widget and icon theme)
        "gtk-2.0/gtkrc".text = ''
          gtk-theme-name="Arc-Darker"
          gtk-cursor-theme-name="Paper"
          gtk-icon-theme-name="Arc"
          gtk-fallback-icon-theme="gnome"
        '';
        # QT4/5 global theme
        "Trolltech.conf".text = ''
          [Qt]
          style=Arc-Darker
        '';
      };
    })
  ];
}
