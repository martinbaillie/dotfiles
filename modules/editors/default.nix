{ config, options, lib, pkgs, ... }:
with lib;
let cfg = config.modules.editors;
in
{
  options.modules.editors = { default = my.mkOpt types.str "nvim"; };

  config = mkIf (cfg.default != null) {
    modules.shell.zsh.env = {
      EDITOR = if cfg.default == "emacs" then "emacs.bash" else cfg.default;
      VISUAL = "$EDITOR";
      GIT_EDITOR = "$EDITOR";
    };
  };
}
