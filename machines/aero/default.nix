# Aero - Personal MacBook Air (early 2014).
{ ... }: {
  imports = [
    ../../.

    <modules/desktop>

    <modules/dev>
    <modules/dev/go.nix>
    <modules/dev/python.nix>

    <modules/editors/emacs.nix>

    <modules/media>

    <modules/term>
    <modules/term/git.nix>
    <modules/term/gnupg.nix>
    <modules/term/zsh.nix>

    <modules/web/chrome.nix>
    <modules/web/firefox.nix>
    <modules/web/zoom.nix>
  ];

  nix = {
    # $ sysctl -n hw.ncpu
    maxJobs = 4;
    buildCores = 4;
  };

  my.casks = [ "workflowy" ];
}
