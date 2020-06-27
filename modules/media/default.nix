{ lib, pkgs, ... }:
let
  inherit (lib) mkMerge mkIf;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; })
    isLinux isDarwin;
in mkMerge [
  (mkIf isDarwin { my.casks = [ "vlc" "transmission-remote-gui" ]; })
  (mkIf isLinux {
    my.packages = with pkgs; [
      alsaUtils
      ffmpeg-full
      gimp
      imagemagick
      lxqt.pavucontrol-qt
      mpv
      transmission-remote-gtk
      vlc
    ];
  })
]
