# Defaults across all my Darwin hosts.
{ ... }: {
  # Keep for nix-darwin backwards compatibility.
  system.stateVersion = 4;

  # Use Daemon mode on macOS.
  services.nix-daemon.enable = true;

  # Use Brew for some macOS App casks that aren't otherwise Nix'd.
  homebrew = {
    enable = true;

    # Keep things deterministic.
    autoUpdate = false;

    # Properly uninstall things.
    cleanup = "zap";

    extraConfig = ''
      cask_args require_sha: true
    '';
    taps = [
      "homebrew/cask"
      "homebrew/core"
      "homebrew/services"
      "homebrew/cask-fonts"
    ];
  };

  # No thanks.
  env.HOMEBREW_NO_ANALYTICS = "1";

  # system.activationScripts.postActivation.text = ''
  #   printf "Disabling Spotlight indexing... "
  #   mdutil -i off -d / &> /dev/null
  #   mdutil -E / &> /dev/null
  #   echo "OK"
  # '';
}
