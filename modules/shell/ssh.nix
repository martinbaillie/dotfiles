{ options, pkgs, config, lib, ... }:
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

        ".ssh/id_rsa".source = config.secrets.id_rsa.path;
        ".ssh/id_rsa.pub".source = "${configDir}/id_rsa.pub";

        ".ssh/id_ed25519".source = config.secrets.id_ed25519.path;
        ".ssh/id_ed25519.pub".source = "${configDir}/id_ed25519.pub";
      };
    }
  ]);
}
