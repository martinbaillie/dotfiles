{ config, options, lib, pkgs, ... }:
with lib;
let cfg = config.modules.web.browser.chromium;
in
{
  options.modules.web.browser.chromium = { enable = my.mkBoolOpt false; };

  config = mkIf cfg.enable (mkMerge [
    (if (builtins.hasAttr "homebrew" options) then {
      # FIXME: Having issues with Chromium derivatives on Darwin so falling back
      # to the fatter parent.
      homebrew.casks = [ "google-chrome" ];
    } else {
      user.packages = [ pkgs.chromium ];
    })
  ]);
}
