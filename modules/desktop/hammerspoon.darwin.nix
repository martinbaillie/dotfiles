{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.modules.desktop.hammerspoon;
  configDir = "${config.dotfiles.configDir}/hammerspoon";
in
{
  options.modules.desktop.hammerspoon = { enable = my.mkBoolOpt false; };

  config = mkIf cfg.enable {
    home.file = {
      ".hammerspoon/Spoons/SpoonInstall.spoon/init.lua".source = builtins.fetchurl {
        # <2021-12-15 Wed>
        url = "https://raw.githubusercontent.com/Hammerspoon/Spoons/1438f747d4a49932a1d2c4911eb05c30b785fb49/Source/SpoonInstall.spoon/init.lua";
        sha256 = "0bm2cl3xa8rijmj6biq5dx4flr2arfn7j13qxbfi843a8dwpyhvk";
      };

      ".hammerspoon/init.lua".source = "${configDir}/init.lua";
      ".hammerspoon/utils.lua".source = "${configDir}/utils.lua";
    };

    #user.packages = [ pkgs.sumneko-lua-language-server ];

    environment.systemPackages = [ pkgs.my.hammerspoon ];
  };
}
