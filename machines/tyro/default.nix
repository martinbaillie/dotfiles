# Tyro - $WORK MacBook Pro.
{ config, pkgs, lib, ... }: {
  imports = [
    ../../.

    <modules/desktop>

    <modules/dev>
    <modules/dev/go.nix>
    <modules/dev/javascript.nix>
    <modules/dev/python.nix>
    <modules/dev/rust.nix>

    <modules/editors/emacs.nix>
    <modules/editors/vim.nix>

    <modules/ops>
    <modules/ops/kafka.nix>
    <modules/ops/kubernetes.nix>
    # <modules/ops/docker.nix>

    <modules/term>
    <modules/term/direnv.nix>
    <modules/term/git.nix>
    <modules/term/gnupg.nix>
    <modules/term/zsh.nix>

    <modules/web/chrome.nix>
    <modules/web/dropbox.nix>
    <modules/web/firefox.nix>
    <modules/web/zoom.nix>
    <modules/web/slack.nix>
  ];

  nix = {
    # $ sysctl -n hw.ncpu
    maxJobs = 4;
    buildCores = 4;
  };

  # Work.
  nixpkgs.overlays = [
    (import (builtins.fetchGit {
      url = config.my.secrets.work_overlay_url;
      ref = "master";
      rev = "14ddc3382c268aca9547d173f00562cedb485f7b";
    }))
  ];

  my = {
    username = "mbaillie";
    email = "mbaillie@tyro.com";
    packages = [ pkgs.corectl ];
    casks = [ "anki" ];
  };
}
