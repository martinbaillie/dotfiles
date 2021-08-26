{ config, lib, pkgs, ... }:
with lib;
let cfg = config.modules.desktop;
in {
  config = mkIf cfg.enable {
    fonts = {
      enableGhostscriptFonts = true;

      fonts = with pkgs; [
        emojione
        font-awesome
        iosevka
        noto-fonts
        weather-icons
      ];

      fontconfig = {
        enable = true;
        defaultFonts = {
          emoji = [ "Noto Color Emoji" "EmojiOne Color" ];
          monospace = [ "Iosevka" "Noto Sans Mono" ];
          sansSerif = [ "Noto Sans" ];
          serif = [ "Noto Serif" ];
        };
      };
    };
  };
}
