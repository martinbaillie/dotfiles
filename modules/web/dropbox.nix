{ lib, pkgs, ... }:
let
  inherit (lib) mkIf mkMerge;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; })
    isLinux isDarwin;
in mkMerge [
  (mkIf isDarwin { my.casks = [ "dropbox" ]; })
  (mkIf isLinux { my.packages = [ pkgs.dropbox-cli ]; })
]
