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

      # Doom One Dark.
      colours = {
        bg = "#282c34";
        bgalt = "#21242b";
        base0 = "#1B2229";
        base1 = "#1c1f24";
        base2 = "#202328";
        base3 = "#23272e";
        base4 = "#3f444a";
        base5 = "#5B6268";
        base6 = "#73797e";
        base7 = "#9ca0a4";
        base8 = "#DFDFDF";
        fg = "#bbc2cf";
        fgalt = "#5B6268";
        grey = "#3f444a";
        red = "#ff6c6b";
        orange = "#da8548";
        green = "#98be65";
        teal = "#4db5bd";
        yellow = "#ECBE7B";
        blue = "#51afef";
        darkblue = "#2257A0";
        magenta = "#c678dd";
        violet = "#a9a1e1";
        cyan = "#46D9FF";
        darkcyan = "#5699AF";
      };
    }

    (mkIf isLinux {
      icons = "${pkgs.paper-icon-theme}/share/icons/Paper-Mono-Dark";
    })
  ];

  my = mkMerge [
    {
      home.xdg.configFile."bat/config".text = ''--theme="OneHalfDark"'';

      # Piggyback wallpaper change trigger to perform imperative theme updates.
      home.xdg.configFile."wallpaper".onChange = "make -B -C ${root} dark";
    }

    (mkIf isLinux {
      env.GTK_THEME = "Arc-Darker";
      packages = with pkgs; [ arc-theme paper-gtk-theme paper-icon-theme ];
      home.xdg.configFile = {
        # GTK
        "gtk-3.0/settings.ini".text = ''
          [Settings]
          gtk-theme-name=Arc-Darker
          gtk-icon-theme-name=Paper-Mono-Dark
          gtk-fallback-icon-theme=gnome
          gtk-application-prefer-dark-theme=true
          gtk-xft-hinting=1
          gtk-xft-hintstyle=hintfull
          gtk-xft-rgba=none
        '';
        # GTK2 global theme (widget and icon theme)
        "gtk-2.0/gtkrc".text = ''
          gtk-theme-name="Arc-Darker"
          gtk-icon-theme-name="Paper-Mono-Dark"
          gtk-font-name="Sans 10"
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
