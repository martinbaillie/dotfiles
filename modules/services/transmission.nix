{ options, config, lib, pkgs, ... }:
with lib;
let
  cfg = config.modules.services.transmission;
  inherit (pkgs.stdenv.targetPlatform) isLinux;
in
{
  options.modules.services.transmission = {
    enable = my.mkBoolOpt false;
    port = my.mkIntOpt 9091;
    flexget.enable = my.mkBoolOpt false;
  };

  config = mkIf cfg.enable (mkMerge [
    (if isLinux then {
      services = {
        transmission = {
          enable = true;
          settings = {
            download-dir = "/media/TRIAGE/";
            incomplete-dir = "/media/.incomplete/";
            incomplete-dir-enabled = true;
            rpc-whitelist = "127.0.0.1,192.168.1.*,192.168.86.*";
            rpc-host-whitelist = "*";
            rpc-bind-address = "0.0.0.0";
            rpc-port = cfg.port;
            ratio-limit = 0.2;
            ratio-limit-enabled = true;
            watch-dir = "/media/.incoming/";
            watch-dir-enabled = true;
          };
        };

        flexget = {
          enable = cfg.flexget.enable;
          user = "transmission";
          homeDir = "/var/lib/transmission";
          systemScheduler = false;
          config = ''
            schedules:
              - tasks: '*'
                interval:
                  minutes: 15

            templates:
              media:
                inputs:
                  - rss: ${config.secrets.showrss_url}
                verify_ssl_certificates: no
                download: /media/.incoming
                quality: webrip+

            tasks:
              media:
                template: media
                accept_all: yes

              clean_up:
                from_transmission:
                  host: 127.0.0.1
                  port: ${toString cfg.port}
                disable: [seen, seen_info_hash]
                if:
                  - transmission_progress == 100: accept
                transmission:
                  host: 127.0.0.1
                  port: ${toString cfg.port}
                  action: purge'';
        };
      };

      user.extraGroups = [ "transmission" ];

      networking.firewall.allowedTCPPorts = [ cfg.port ];
    } else { })
  ]);
}
