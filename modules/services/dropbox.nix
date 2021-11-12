{ config, options, lib, pkgs, ... }:
with lib;
let cfg = config.modules.services.dropbox;
in
{
  options.modules.services.dropbox = { enable = my.mkBoolOpt false; };

  config = mkIf cfg.enable (mkMerge [
    (if (builtins.hasAttr "homebrew" options) then {
      homebrew.casks = [ "dropbox" ];
    } else
      with pkgs; {
        user.packages = [ dropbox-cli ];

        # NOTE: Run a one-off `dropbox start` to configure in the browser.
        systemd.user.services.dropbox = {
          description = "Dropbox";

          wantedBy = [ "graphical-session.target" ];

          environment = {
            QT_PLUGIN_PATH = "/run/current-system/sw/"
              + qt5.qtbase.qtPluginPrefix;
            QML2_IMPORT_PATH = "/run/current-system/sw/"
              + qt5.qtbase.qtQmlPrefix;
          };

          serviceConfig = {
            ExecStart = "${dropbox.out}/bin/dropbox";
            ExecReload = "${coreutils.out}/bin/kill -HUP $MAINPID";
            KillMode = "control-group"; # upstream recommends process
            Restart = "on-failure";
            PrivateTmp = true;
            ProtectSystem = "full";
            Nice = 10;
          };
        };
      })
  ]);
}
