{ lib, ... }: {
  imports = let
    inherit (lib.systems.elaborate { system = builtins.currentSystem; })
      isLinux;
  in if isLinux then [ ./docker.linux.nix ] else [ ./docker.darwin.nix ];
}
