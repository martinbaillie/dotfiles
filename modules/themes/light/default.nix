{ lib, config, pkgs, ... }:
with lib;
with lib.my;
let cfg = config.modules.theme;
in
{
  config = mkIf (cfg.mode == "light") {
    modules.theme = {
      wallpaper = ./dj_nobu_light.jpg;
      colours = import ./_solarized_light.nix;
      tridactyl = "base16-solarized-light";
    };

    home = {
      configFile = {
        # Piggyback wallpaper change trigger to perform non-Nix managed updates.
        "wallpaper".onChange = "make -B -C /etc/dotfiles light";

        "bat/config".text = ''--theme="Solarized (light)"'';
      };
    };
  };
}
