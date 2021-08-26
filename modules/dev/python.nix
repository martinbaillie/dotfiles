{ config, lib, pkgs, ... }:
with lib;
let cfg = config.modules.dev.python;
in {
  options.modules.dev.python = { enable = my.mkBoolOpt false; };

  config = mkIf cfg.enable {
    user.packages = with pkgs;
      [
        (python39.withPackages (ps:
          with ps; [
            black
            isort
            pip
            pipenv
            pyflakes
            pylint

            # FIXME: arm64.
            # python-lsp-server

            setuptools
            virtualenv
          ]))
      ];
  };
}
