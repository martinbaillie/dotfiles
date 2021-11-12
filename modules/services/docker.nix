{ options, config, lib, pkgs, ... }:
with lib;
let cfg = config.modules.services.docker;
in
{
  options.modules.services.docker = { enable = my.mkBoolOpt false; };

  config = mkIf cfg.enable (mkMerge [
    (if (builtins.hasAttr "homebrew" options) then {
      homebrew.casks = [ "docker" ];
    } else {
      user = {
        packages = with pkgs; [ docker docker-compose ];
        extraGroups = [ "docker" ];
      };

      services.openssh = {
        enable = true;
        startWhenNeeded = true;
        forwardX11 = true;
        challengeResponseAuthentication = false;
        passwordAuthentication = false;
        permitRootLogin = "no";
      };
    })
    {
      user.packages = [ pkgs.nodePackages.dockerfile-language-server-nodejs ];

      env = {
        DOCKER_CONFIG = "$XDG_CONFIG_HOME/docker";
        MACHINE_STORAGE_PATH = "$XDG_DATA_HOME/docker/machine";
      };
    }
  ]);
}
