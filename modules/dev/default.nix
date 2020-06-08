{ pkgs, lib, ... }: {
  imports = let
    inherit (lib.systems.elaborate { system = builtins.currentSystem; })
      isLinux;
  in if isLinux then [ ./default.linux.nix ] else [ ./default.darwin.nix ];
  my.packages = with pkgs; [ gnumake cmake shellcheck nixfmt niv ];
}
