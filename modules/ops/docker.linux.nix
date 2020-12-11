{ pkgs, ... }: {
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  my = {
    packages = with pkgs; [ docker docker-compose ];
    user.extraGroups = [ "docker" ];
  };
}
