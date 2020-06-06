{ lib, pkgs, ... }:
let
  inherit (lib) mkMerge mkIf;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; })
    isLinux isDarwin;
in {
  my = mkMerge [
    (mkIf isDarwin { casks = [ "slack" ]; })
    (mkIf isLinux { packages = with pkgs; [ slack ]; })
    # REVIEW: Awaiting decent native Electron support for Wayland.
    # https://github.com/electron/electron/issues/10915
    #   my.packages = let
    #     wrapper = with pkgs;
    #       writeShellScriptBin "slack" ''
    #         GDK_BACKEND=x11 ${slack}/bin/slack $@
    #       '';
    #   in with pkgs; [ wrapper ];
  ];
}
