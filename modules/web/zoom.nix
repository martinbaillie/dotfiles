{ config, options, lib, pkgs, ... }:
with lib;
let cfg = config.modules.web.zoom;
in
{
  options.modules.web.zoom = { enable = my.mkBoolOpt false; };

  config = mkIf cfg.enable (mkMerge [
    # No Zoom package for Darwin.
    (if (builtins.hasAttr "homebrew" options) then {
      homebrew.casks = [ "zoom" ];
    } else {
      user.packages = [ pkgs.zoom ];
    })
  ]);
}
