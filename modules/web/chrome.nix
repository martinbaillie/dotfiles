{ lib, pkgs, ... }:
let
  inherit (lib) mkMerge mkIf;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; })
    isLinux isDarwin;
in {
  my = mkMerge [
    (mkIf isDarwin { casks = [ "google-chrome" ]; })
    (mkIf isLinux { packages = with pkgs; [ chromium ]; })
  ];
}
