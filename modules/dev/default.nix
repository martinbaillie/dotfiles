{ config, options, lib, pkgs, ... }:
with lib;
let cfg = config.modules.dev;
in
{
  options.modules.dev = { enable = my.mkBoolOpt false; };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      cmake
      nixpkgs-fmt
      nodePackages.bash-language-server
      marksman
      rnix-lsp
      shellcheck
      shfmt
    ];
  };
}
