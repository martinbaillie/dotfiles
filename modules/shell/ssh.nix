{ options, pkgs, config, lib, inputs, ... }:
with lib;
let
  cfg = config.modules.shell.ssh;
  configDir = "${config.dotfiles.configDir}/ssh";
in
{
  options.modules.shell.ssh = { enable = my.mkBoolOpt false; };

  config = mkIf cfg.enable (mkMerge [
    {
      user.packages = [
        # NOTE: To stop sending carriage returns on accidental press:
        # 1. Find slot: `ykman otp info`
        # 2. Disable: `ykman otp settings --no-enter 1`
        pkgs.yubikey-manager
      ];

      home.file = {
        ".ssh/config".source = "${configDir}/config";

        ".ssh/id_rsa".text = config.secrets.id_rsa;
        ".ssh/id_rsa.pub".source = "${configDir}/id_rsa.pub";

        ".ssh/id_ed25519".text = config.secrets.id_ed25519;
        ".ssh/id_ed25519.pub".source = "${configDir}/id_ed25519.pub";
      };
    }
    (mkIf config.targetSystem.isLinux {
      user.openssh.authorizedKeys.keyFiles =
        mapAttrsToList (n: _: "${configDir}/${n}")
          (filterAttrs (n: v: v == "regular" && (hasSuffix ".pub" n))
            (builtins.readDir "${configDir}"));
    })
    (mkIf config.targetSystem.isDarwin {
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
            ''; in
        dag.entryAfter [ "writeBoundary" ] ''
          install -D -m600 ${
            pkgs.callPackage mkAuthorizedKeys { }
          } $HOME/.ssh/authorized_keys
        '';
    })
  ]);
}
