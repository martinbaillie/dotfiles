{ inputs, lib, pkgs, darwin, ... }:

with lib;
with lib.my;
with darwin.lib;
with builtins;
{
  mkHost = path:
    attrs@{ system, ... }:
    let
      isNixOS = strings.hasInfix "linux" system;
      hostname = baseNameOf path;
      # TODO: Improve theming technique.
      theme = "${(getEnv "XDG_DATA_HOME")}/theme.nix";
      private = "${(getEnv "XDG_DATA_HOME")}/${hostname}.nix";
      hardware = "${path}/hardware-configuration.nix";
      commonModules = [
        rec {
          networking.hostName = mkDefault hostname;
          environment = {
            variables.HOSTNAME = networking.hostName;
          };
        }
        (filterAttrs (n: v: !elem n [ "system" ]) attrs)

        # Host-specific settings.
        ../hosts # 1. All hosts (i.e. Darwin AND Linux, aarch64 AND x86_64).
        (dirOf (dirOf path)) # 2. Current platform (i.e. Darwin OR Linux)
        (dirOf path) # 3. Current architecture (e.g. aarch64, x86_64).
        (import path) # 4. Current host.
      ] ++ (mapModulesRec' ../modules import) # Make all my modules available.
      ++ (optional (pathExists theme) private) # Current host private settings.
      ++ (optional (pathExists theme) theme); # Current host theme.
      specialArgs = {
        inherit lib inputs;
        pkgs = pkgs.${system};
      };
    in
    if isNixOS then
      makeOverridable nixosSystem
        {
          inherit specialArgs;
          modules = [
            ({ config, pkgs, ... }: {
              imports = [
                inputs.home-manager.nixosModules.home-manager
                inputs.bad-hosts.nixosModule
                inputs.sops-nix.nixosModules.sops
              ];
            })
          ] ++ (optional (pathExists hardware) (hardware)) ++ commonModules;
        }
    else
      makeOverridable darwinSystem {
        inherit specialArgs system;
        modules = [
          ({ config, pkgs, ... }: {
            imports = [
              inputs.home-manager.darwinModules.home-manager
              inputs.sops-nix.darwinModules.sops
            ];
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
