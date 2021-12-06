{ options, config, lib, pkgs, ... }:
with lib;
let cfg = config.modules.services.docker;
in
{
  options.modules.services.docker = { enable = my.mkBoolOpt false; };

  config = mkIf cfg.enable (mkMerge [
    (if (builtins.hasAttr "homebrew" options) then {
      homebrew.brews = [
        # TODO: Needs Nixpkgs to catch up to 0.7.3
        "lima"
      ];

      # Make the Lima VM Docker (Moby) socket available to the host.
      env.DOCKER_HOST = "unix://$HOME/.docker/docker.sock";
    } else {
      user.extraGroups = [ "docker" ];

      services.openssh = {
        enable = true;
        startWhenNeeded = true;
        forwardX11 = true;
        challengeResponseAuthentication = false;
        passwordAuthentication = false;
        permitRootLogin = "no";
      };

      env = {
        DOCKER_CONFIG = "$XDG_CONFIG_HOME/docker";
        MACHINE_STORAGE_PATH = "$XDG_DATA_HOME/docker/machine";
      };
    })
    {
      user.packages = with pkgs; [
        # On Darwin this is just the client and the compose / buildkit plugins.
        docker

        # Provide compatibility for things still using docker hyphen compose.
        (writeShellScriptBin "docker-compose" "docker compose $@")

        nodePackages.dockerfile-language-server-nodejs
      ];
    }
  ]);
}
