{ config, lib, pkgs, ... }: {
  imports = [
    # Nix Darwin version of home-manager.
    <home-manager/nix-darwin>
  ];

  environment.shells = [ pkgs.zsh ];

  # Used for backwards compatibility.
  # Read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  nix = {
    # Auto-upgrade Nix package.
    package = pkgs.nix;

    gc = {
      # Automatically run the Nix garbage collector.
      automatic = true;

      # Run the collector as the current user.
      user = config.my.username;

      options = "--delete-older-than 10d";
    };

    # Users that have additional rights when connecting to the Nix daemon.
    trustedUsers = [ "root" "@admin" config.my.username ];
  };

  # Auto-upgrade the daemon service.
  services.nix-daemon.enable = true;
  services.nix-daemon.enableSocketListener = true;

  # Install per-user packages.
  home-manager.useUserPackages = true;
}
