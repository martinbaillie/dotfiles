{ lib, config, pkgs, ... }:
with lib;
with lib.my;
let cfg = config.modules.theme;
in
{
  config = mkIf (cfg.mode == "dark") {
    modules.theme = {
      wallpaper = ./dj_nobu_dark.jpg;
      colours = import ./_dracula.nix;
      tridactyl = "base16-dracula";
    };

    home = {
      configFile = {
        # Piggyback wallpaper change trigger to perform non-Nix managed updates.
        "wallpaper".onChange = "make -B -C /etc/dotfiles dark";

        "bat/config".text = ''--theme="Dracula"'';
      };
    };
  };
}
