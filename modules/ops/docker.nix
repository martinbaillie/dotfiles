{ lib, pkgs, ... }:
let
  inherit (lib) mkMerge mkIf;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; })
    isLinux isDarwin;
in {
  my = mkMerge [
    (mkIf isDarwin { casks = [ "docker" ]; })
    (mkIf isLinux {
      packages = with pkgs; [ docker docker-compose ];
      user.extraGroups = [ "docker" ];
    })
  ];
}
