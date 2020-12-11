{ lib, pkgs, ... }:
let
  inherit (lib) mkMerge mkIf;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; })
    isLinux isDarwin;
in {
  my = mkMerge [
    (mkIf isDarwin { casks = [ "zoom" ]; })
    (mkIf isLinux { packages = with pkgs; [ zoom-us ]; })
  ];
}
