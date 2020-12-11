{ pkgs, ... }: {
  # NOTE: (NixOS) run a one-off `dropbox start` to configure in the browser.
  systemd.user.services.dropbox = {
    description = "Dropbox";
    wantedBy = [ "graphical-session.target" ];
    environment = {
      QT_PLUGIN_PATH = "/run/current-system/sw/"
        + pkgs.qt5.qtbase.qtPluginPrefix;
      QML2_IMPORT_PATH = "/run/current-system/sw/"
        + pkgs.qt5.qtbase.qtQmlPrefix;
    };
    serviceConfig = {
      ExecStart = "${pkgs.unstable.dropbox.out}/bin/dropbox";
      ExecReload = "${pkgs.coreutils.out}/bin/kill -HUP $MAINPID";
      KillMode = "control-group"; # upstream recommends process
      Restart = "on-failure";
      PrivateTmp = true;
      ProtectSystem = "full";
      Nice = 10;
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 17500 ];
    allowedUDPPorts = [ 17500 ];
  };

  my.packages = [ pkgs.unstable.dropbox-cli ];
}
