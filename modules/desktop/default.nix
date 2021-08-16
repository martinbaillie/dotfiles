{ config, options, lib, pkgs, ... }:
with lib; {
  options.modules.desktop = {
    enable = my.mkBoolOpt false;

    wm = mkOption {
      type = types.nullOr (types.enum [ "exwm" "sway" "yabai" ]);
      description = ''
        The window manager to use for this desktop system.
      '';
      default = null;
    };

    dpi = mkOption {
      type = types.int;
      description = ''
        The font DPI to use for this desktop system.
      '';
      default = 96;
    };

    hidpi = mkOption {
      type = types.bool;
      description = ''
        This desktop system has an HiDPI display.
      '';
      default = false;
    };
  };
}
