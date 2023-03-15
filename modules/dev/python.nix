{ config, lib, pkgs, ... }:
with lib;
let cfg = config.modules.dev.python;
in
{
  options.modules.dev.python = { enable = my.mkBoolOpt false; };

  config = mkIf cfg.enable {
    user.packages =
      [
        (pkgs.python39.withPackages
          (ps: with ps; [ python-lsp-black python-lsp-server ]
            ++ optional config.modules.editors.emacs.enable grip))
      ];
  };
}
