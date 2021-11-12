{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.modules.web.browser.nyxt;
  configDir = "${config.dotfiles.configDir}/nyxt";
in
{
  options.modules.web.browser.nyxt = { enable = my.mkBoolOpt false; };

  config = mkIf cfg.enable {
    user.packages = [ pkgs.nyxt ];

    home.configFile."nyxt/init.org" =
      let target = "${(builtins.getEnv "XDG_CONFIG_HOME")}/nyxt/init.org";
      in
      {
        source = "${configDir}/nyxt.org";
        onChange = ''
          emacs --batch --eval "(require 'org)" \
            --eval '(org-babel-tangle-file "${target}")'
        '';
      };
  };
}
