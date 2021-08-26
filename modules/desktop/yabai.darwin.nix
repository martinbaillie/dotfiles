{ config, lib, ... }:
with lib;
let cfg = config.modules.desktop.wm;
in { config = mkIf (cfg.wm == "yabai") { }; }
