{ options, config, pkgs, lib, ... }:
with lib;
let
  cfg = config.modules.services.ssh;
  inherit (pkgs.stdenv.targetPlatform) isLinux;
in
{
  options.modules.services.ssh = { enable = my.mkBoolOpt false; };

  config = mkIf cfg.enable (mkMerge [
    (if isLinux then {
      services.openssh = {
        enable = true;
        startWhenNeeded = true;
        forwardX11 = true;
        kbdInteractiveAuthentication = false;
        passwordAuthentication = false;
        permitRootLogin = "no";
      };
    } else
      {
        # darwin
      })
    {
      # shared
    }
  ]);
}
