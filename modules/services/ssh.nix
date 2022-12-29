{ options, config, pkgs, lib, inputs, ... }:
with lib;
let
  cfg = config.modules.services.ssh;
  configDir = "${config.dotfiles.configDir}/ssh";
  inherit (pkgs.stdenv.targetPlatform) isLinux;
in
{
  options.modules.services.ssh = { enable = my.mkBoolOpt false; };

  config = mkIf cfg.enable (mkMerge [
    (if isLinux then {
      services.openssh = {
        enable = true;
        startWhenNeeded = true;
        forwardX11 = true;
        kbdInteractiveAuthentication = false;
        passwordAuthentication = false;
        permitRootLogin = "no";
      };

      user.openssh.authorizedKeys.keyFiles =
        mapAttrsToList (n: _: "${configDir}/${n}")
          (filterAttrs (n: v: v == "regular" && (hasSuffix ".pub" n))
            (builtins.readDir "${configDir}"));
    } else {
      # Darwin.
      # NOTE: SSH service provided by macOS.
      home.activation.authorizedKeys =
        let
          inherit (inputs.home-manager.lib.hm) dag;
          inherit (lib) mkMerge mkIf concatMapStrings;
          mkAuthorizedKeys = { runCommand }:
            runCommand "authorized_keys"
              {
                source = builtins.toFile "authorized_keys"
                  (concatMapStrings builtins.readFile [
                    "${configDir}/id_rsa.pub"
                    "${configDir}/id_ed25519.pub"
                  ]);
              } ''
              sed -s '$G' $source > $out
            '';
        in
        dag.entryAfter [ "writeBoundary" ] ''
          install -D -m600 ${
            pkgs.callPackage mkAuthorizedKeys { }
          } $HOME/.ssh/authorized_keys
        '';
    })
    {
      # Shared.
    }
  ]);
}
