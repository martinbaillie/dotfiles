{ lib, config, pkgs, ... }:
with pkgs;
with lib;
with lib.my;
let cfg = config.modules.theme;
in
{
  config = mkIf (cfg.mode == "light") {
    user.packages = [
      solarc-gtk-theme
      arc-theme
      arc-icon-theme
      paper-gtk-theme
      paper-icon-theme
    ];

    modules.theme.icons = "${paper-icon-theme}/share/icons/Paper";

    modules.shell.zsh.env.GTK_THEME = "SolArc";

    home.configFile = {
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
  };
}
