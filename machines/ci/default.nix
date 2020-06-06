{ pkgs, lib, ... }:
# For CI, import every module but select a single theme, ultimately testing both
# themes over the course of the NixOS and macOS CI runs. Also filter out any
# system specific modules that are not for the current system.
let
  inherit (builtins) readDir concatLists filter match;
  inherit (lib) mapAttrsToList hasSuffix;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; }) isLinux;
  nixFilesIn = dir:
    let
      children = readDir dir;
      f = path: type:
        let absPath = dir + "/${path}";
        in if type == "directory" then
          nixFilesIn absPath
        else if hasSuffix ".nix" (baseNameOf path) then
          [ absPath ]
        else
          [ ];
    in concatLists (mapAttrsToList f children);
  modules = filter (n:
    match
    ("(.*/themes/.*|.*." + (if isLinux then "darwin" else "linux") + ".nix$)")
    (toString n) == null) (nixFilesIn <modules>);
  theme = (if isLinux then <modules/themes/light> else <modules/themes/dark>);
in { imports = [ ../../. theme ] ++ modules; }
