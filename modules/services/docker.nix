{ options, config, lib, pkgs, ... }:
with lib;
let cfg = config.modules.services.docker;
in
{
  options.modules.services.docker = { enable = my.mkBoolOpt false; };

  config = mkIf cfg.enable (mkMerge [
    (if (builtins.hasAttr "homebrew" options) then {
      homebrew = {
        brews = [
          # $WORK has Docker for Desktop licenses so use it out of laziness.
          # Lima is great though.
          # "lima"
        ];

        casks = [ "docker" ];
      };

      # Make the Lima VM Docker (Moby) socket available to the host.
      # env.DOCKER_HOST = "unix://$HOME/.docker/docker.sock";
    } else {
      user.extraGroups = [ "docker" ];

      user.packages = [
        docker

        # Provide compatibility for things still using docker hyphen compose.
        (writeShellScriptBin "docker-compose" "docker compose $@")
      ];

      # TODO: Linux service whenever I actually have a need for a Docker daemon
      # on NixOS.

      env = {
        DOCKER_CONFIG = "$XDG_CONFIG_HOME/docker";
        MACHINE_STORAGE_PATH = "$XDG_DATA_HOME/docker/machine";
      };
    })
    {
      user.packages = with pkgs; [
        nodePackages.dockerfile-language-server-nodejs
      ];
    }
  ]);
}
