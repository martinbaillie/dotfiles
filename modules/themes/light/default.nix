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
      wallpaper = ./dj_nobu_light.jpg;
      colours = import ./doom_solarized_light.nix;
      tridactyl = "base16-solarized-light";
    }

    (mkIf isLinux { icons = "${pkgs.paper-icon-theme}/share/icons/Paper"; })
  ];

  my = mkMerge [
    {
      home.xdg.configFile."bat/config".text = ''--theme="Solarized (light)"'';

      # Piggyback wallpaper change trigger to perform imperative theme updates.
      home.xdg.configFile."wallpaper".onChange = "make -B -C ${root} light";
    }

    (mkIf isLinux {
      env.GTK_THEME = "SolArc";
      packages = with pkgs; [
        solarc-gtk-theme
        arc-theme
        arc-icon-theme
        paper-gtk-theme
        paper-icon-theme
      ];
      home.xdg.configFile = {
        # GTK
        "gtk-3.0/settings.ini".text = ''
          [Settings]
          gtk-theme-name=SolArc
          gtk-icon-theme-name=Arc
          gtk-fallback-icon-theme=gnome
          gtk-application-prefer-dark-theme=false
          gtk-xft-hinting=1
          gtk-xft-hintstyle=hintfull
          gtk-xft-rgba=none
        '';
        # GTK2 global theme (widget and icon theme)
        "gtk-2.0/gtkrc".text = ''
          gtk-theme-name="SolArc"
          gtk-icon-theme-name="Arc"
          gtk-cursor-theme-name="Paper"
          gtk-fallback-icon-theme="gnome"
        '';
        # QT4/5 global theme
        "Trolltech.conf".text = ''
          [Qt]
          style=SolArc
        '';
      };
    })
  ];
}
