{ config, lib, pkgs, ... }:
with lib;
let cfg = config.modules.dev.python;
in
{
  options.modules.dev.python = { enable = my.mkBoolOpt false; };

  config = mkIf cfg.enable {
    user.packages =
      [
        ((pkgs.python39.override {
          packageOverrides = python-self: python-super: {
            python-lsp-server = (python-super.python-lsp-server.override
              {
                # We use `black` at $JOB.
                withAutopep8 = false;
                withYapf = false;
              }).overridePythonAttrs
              (oldAttrs: {
                doCheck = false;
                checkInputs = [ ];
              });
          };
        }).withPackages
          (ps: with ps; [ python-lsp-black python-lsp-server ] ++ optional
            config.modules.editors.emacs.enable
            grip))
      ];
  };
}
