{ config, options, lib, pkgs, ... }:
with lib;
let cfg = config.modules.ops.kafka;
in
{
  options.modules.ops.kafka = { enable = my.mkBoolOpt false; };
  config = mkIf cfg.enable { user.packages = with pkgs; [ kafkacat ]; };
}
