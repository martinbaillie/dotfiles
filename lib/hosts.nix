{ inputs, lib, pkgs, darwin, ... }:

with lib;
with lib.my;
with darwin.lib; {
  mkHost = path:
    attrs@{ system, ... }:
    let
      isNixOS = strings.hasInfix "linux" system;
      theme = "${(builtins.getEnv "XDG_DATA_HOME")}/theme.nix";
      commonModules = [
        rec {
          networking.hostName =
            mkDefault (removeSuffix ".nix" (baseNameOf path));
          environment.variables.HOSTNAME = networking.hostName;
        }
        (filterAttrs (n: v: !elem n [ "system" ]) attrs)
        ../hosts # 1. All hosts (i.e. Darwin AND Linux, aarch64 AND x86_64).
        (dirOf (dirOf path)) # 2. Current platform (i.e. Darwin OR Linux)
        (dirOf path) # 3. Current architecture (e.g. aarch64, x86_64).
        (import path) # 4. Current host.
      ] ++
        # Current host theme.
        (optional (pathExists theme) theme);
      specialArgs = {
        inherit lib inputs;
        pkgs = pkgs.${system};
      };
    in if isNixOS then
      nixosSystem {
        inherit system specialArgs;
        modules = [{ nixpkgs.pkgs = pkgs.${system}; }] ++ commonModules;
      }
    else
      darwinSystem {
        inherit specialArgs;
        modules = [
          ({ config, pkgs, ... }: {
            imports = [ inputs.home-manager.darwinModules.home-manager ]
              ++ (mapModulesRec' ../modules import);
          })
        ] ++ commonModules;
      };

  mapHosts = dir:
    attrs@{ system ? system, ... }:
    mapModules dir (hostPath: mkHost hostPath attrs);

  mkConfiguration = basePath: system:
    mapHosts (basePath + ("/" + (head (splitString "-" system)))) {
      inherit system;
    };

  mapConfigurations = supportedSystems: basePath:
    foldAttrs (a: b: a // b) { }
    (forEach supportedSystems (system: (mkConfiguration basePath system)));
}
