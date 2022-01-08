{ config, lib, pkgs, ... }:
with lib;
let cfg = config.modules.dev.protobuf;
in
{
  options.modules.dev.protobuf = {
    enable = my.mkBoolOpt false;
    grpc.enable = my.mkBoolOpt false;
  };

  config = mkIf cfg.enable { };
}
