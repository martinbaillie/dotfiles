{ config, pkgs, lib, ... }:
with pkgs;
with import <home-manager/modules/lib/dag.nix> { inherit lib; };
let
  inherit (lib) mkMerge mkIf concatMapStrings;
  mkAuthorizedKeys = { runCommand }:
    runCommand "authorized_keys" {
      source = builtins.toFile "authorized_keys"
        (concatMapStrings builtins.readFile [
          <config/ssh/id_rsa.pub>
          <config/ssh/id_ed25519.pub>
        ]);
    } ''
      sed -s '$G' $source > $out
    '';
in {
  my = {
    home = {
      home = {
        file = {
          ".ssh/config".source = <config/ssh/config>;
          ".ssh/id_rsa".text = config.my.secrets.id_rsa;
          ".ssh/id_rsa.pub".source = <config/ssh/id_rsa.pub>;
          ".ssh/id_ed25519".text = config.my.secrets.id_ed25519;
          ".ssh/id_ed25519.pub".source = <config/ssh/id_ed25519.pub>;
        };
        activation.authorizedKeys = dagEntryAfter [ "writeBoundary" ] ''
          install -D -m600 ${
            callPackage mkAuthorizedKeys { }
          } $HOME/.ssh/authorized_keys
        '';
      };
    };
  };
}
