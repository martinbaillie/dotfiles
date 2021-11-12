let flake = builtins.getFlake (toString ./.);
in
{
  inherit flake;
} // flake // flake.inputs // builtins // flake.inputs.nixpkgs.lib
// flake.nixosConfigurations
// flake.nixosConfigurations.${builtins.getEnv "HOSTNAME"} or { }
// flake.darwinConfigurations
  // flake.darwinConfigurations.${builtins.getEnv "HOSTNAME"} or { }
