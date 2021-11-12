{ config, options, lib, pkgs, ... }:
with lib;
let cfg = config.modules.web.slack;
in
{
  options.modules.web.slack = { enable = my.mkBoolOpt false; };

  config = mkIf cfg.enable (mkMerge [
    # Slack @ nixpkgs on Darwin broken.
    # FIXME: https://github.com/NixOS/nixpkgs/pull/125051
    (if (builtins.hasAttr "homebrew" options) then {
      homebrew.casks = [ "slack" ];
    } else {
      user.packages = [ pkgs.slack ];
    })
  ]);
}
