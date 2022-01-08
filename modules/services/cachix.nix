{ options, config, pkgs, lib, ... }:
with lib;
let
  cfg = config.modules.services.cachix;
  inherit (pkgs.stdenv.targetPlatform) isLinux;
in
{
  options.modules.services.cachix = { enable = my.mkBoolOpt false; };

  config =
    let
      cachix = "${pkgs.cachix}/bin/cachix -v watch-store martinbaillie";
      common = {
        environment = {
          XDG_CACHE_HOME = "/var/cache/cachix-watch-store";
          CACHIX_AUTH_TOKEN = config.secrets.cachix_auth_token;
        };
        path = [ config.nix.package ];
      };
    in
    mkIf cfg.enable (mkMerge [
      (if isLinux then {
        systemd.services.cachix-watch-store = {
          description = "Cachix store watcher service";
          wantedBy = [ "multi-user.target" ];
          after = [ "network-online.target" ];
          serviceConfig = {
            Restart = "always";
            RestartSec = 5;
            TimeoutSec = 5;
            CacheDirectory = "cachix-watch-store";
            ExecStart = cachix;
          };
          unitConfig.StartLimitIntervalSec = 0;
        } // common;
      } else {
        launchd.user.agents.cachix-watch-store = {
          serviceConfig = {
            KeepAlive = true;
            RunAtLoad = true;
            StandardOutPath = "/tmp/cachix-watch-store.stdout";
            StandardErrorPath = "/tmp/cachix-watch-store.stderr";
          };
          command = cachix;
        } // common;
      })
      {
        # shared
      }
    ]);
}
