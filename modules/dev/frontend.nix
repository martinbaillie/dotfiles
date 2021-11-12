{ config, lib, pkgs, ... }:
with lib;
let cfg = config.modules.dev.frontend;
in
{
  options.modules.dev.frontend = { enable = my.mkBoolOpt false; };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      nodePackages.vscode-css-languageserver-bin
      nodePackages.vscode-html-languageserver-bin
    ];
  };
}
