{ config, options, lib, pkgs, ... }:
with lib;
let cfg = config.modules.shell.direnv;
in
{
  options.modules.shell.direnv = { enable = my.mkBoolOpt false; };

  config = mkIf cfg.enable {
    home.programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    modules.shell.zsh.rc = ''eval "$(direnv hook zsh)"'';
    env.DIRENV_WARN_TIMEOUT = "30s";
    env.DIRENV_LOG_FORMAT = "";
  };
}
