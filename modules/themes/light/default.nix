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

      # Doom One Light.
      colours = {
        bg = "#fafafa";
        bgalt = "#f0f0f0";
        base0 = "#f0f0f0";
        base1 = "#e7e7e7";
        base2 = "#dfdfdf";
        base3 = "#c6c7c7";
        base4 = "#9ca0a4";
        base5 = "#383a42";
        base6 = "#202328";
        base7 = "#1c1f24";
        base8 = "#1b2229";
        fg = "#383a42";
        fgalt = "#c6c7c7";
        grey = "#9ca0a4";
        red = "#e45649";
        orange = "#da8548";
        green = "#50a14f";
        teal = "#4db5bd";
        yellow = "#986801";
        blue = "#4078f2";
        darkblue = "#a0bcf8";
        magenta = "#a626a4";
        violet = "#b751b6";
        cyan = "#0184bc";
        darkcyan = "#005478";
      };
    }

    (mkIf isLinux { icons = "${pkgs.paper-icon-theme}/share/icons/Paper"; })
  ];

  my = mkMerge [
    {
      home.xdg.configFile."bat/config".text = ''--theme="OneHalfLight"'';

      # Piggyback wallpaper change trigger to perform imperative theme updates.
      home.xdg.configFile."wallpaper".onChange = "make -B -C ${root} light";
    }

    (mkIf isLinux {
      env.GTK_THEME = "Arc";
      packages = with pkgs; [ paper-gtk-theme paper-icon-theme ];
      home.xdg.configFile = {
        # GTK
        "gtk-3.0/settings.ini".text = ''
          [Settings]
          gtk-theme-name=Adwaita
          gtk-icon-theme-name=Paper
          gtk-fallback-icon-theme=gnome
          gtk-application-prefer-dark-theme=false
          gtk-xft-hinting=1
          gtk-xft-hintstyle=hintfull
          gtk-xft-rgba=none
        '';
        # GTK2 global theme (widget and icon theme)
        "gtk-2.0/gtkrc".text = ''
          gtk-theme-name="Adwaita"
          gtk-icon-theme-name="Paper"
          gtk-font-name="Sans 10"
        '';
        # QT4/5 global theme
        "Trolltech.conf".text = ''
          [Qt]
          style=Adwaita
        '';
      };
    })
  ];
}
