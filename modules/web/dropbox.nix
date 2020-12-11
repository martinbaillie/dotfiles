{ lib, ... }: {
  imports = let
    inherit (lib.systems.elaborate { system = builtins.currentSystem; })
      isLinux;
  in if isLinux then [ ./dropbox.linux.nix ] else [ ./dropbox.darwin.nix ];
}
