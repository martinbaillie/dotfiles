# Defaults across all my hosts and platforms (both NixOS and Darwin).
{ inputs, config, lib, pkgs, ... }:

with lib; {
  nix =
    let
      # Caching.
      mkCache = url: key: { inherit url key; };
      martinbaillie = mkCache "https://martinbaillie.cachix.org"
        "martinbaillie.cachix.org-1:clUspg2ke4PWimP2gYEtm1/lvbcDDEc8yFP6lgOiqlQ=";
      cache = mkCache "https://cache.nixos.org"
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
      cachix = mkCache "https://cachix.cachix.org"
        "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM=";
      nix-community = mkCache "https://nix-community.cachix.org"
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
      all = [ martinbaillie cache cachix nix-community ];

      # Flake inputs sans `self` for system registry and Nix path uses.
      filteredInputs = filterAttrs (n: _: n != "self") inputs;
    in
    {
      # My trusted binary caches.
      settings = {
        substituters = map (x: x.url) all;
        trusted-public-keys = map (x: x.key) all;
      };

      extraOptions = ''
        # Control binary cache connections.
        binary-caches-parallel-connections = 50
        connect-timeout = 5
        # Enable the Nix 2.0 CLI and Flakes support.
        experimental-features = nix-command flakes
        # Shutup warnings about dirty repo.
        warn-dirty = false
      '';

      # Use the Flakes edition of Nix.
      package = pkgs.unstable.nix;

      nixPath = (mapAttrsToList (n: v: "${n}=${v}") filteredInputs) ++ [
        "nixpkgs-overlays=${config.dotfiles.dir}/overlays"
        "dotfiles=${config.dotfiles.dir}"
      ];

      # Build a system registry of the inputs for ease of reference.
      # NOTE: global registry @ https://github.com/NixOS/flake-registry
      registry = (mapAttrs (_: v: { flake = v; }) filteredInputs) // {
        dotfiles.flake = inputs.self;
      };
    };

  environment = {
    systemPackages = with pkgs; [
      cachix
      neofetch
      # TODO unstable.nix-output-monitor
    ];
    variables = {
      # Force XDG defaults as soon as possible.
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_BIN_HOME = "$HOME/.local/bin";
      XDG_DESKTOP_DIR = "$HOME"; # prevent creation of ~/Desktop
      XDG_RUNTIME_DIR =
        if config.targetSystem.isLinux then
          "/run/user/$UID"
        else
          "$XDG_DATA_HOME";

      # Set up Cachix for personal binary caching.
      CACHIX_AUTH_TOKEN = config.secrets.cachix_auth_token;

      # Location, timezone and internationalisation.
      TZ = "Australia/Sydney";
      LC_ALL = "en_AU.UTF-8";
      LANG = "en_AU.UTF-8";
      LANGUAGE = "en_AU.UTF-8";

      # Needs must.
      NIXPKGS_ALLOW_UNFREE = "1";
    };
  };

  modules.shell.zsh.aliases = {
    nix-test = "make -C /etc/dotfiles test";
    nix-switch = "make -C /etc/dotfiles switch";
    nix-rollback = "make -C /etc/dotfiles switch --rollback";
    dark = "make -B -C /etc/dotfiles nix-switch-theme NIX_THEME=dark";
    light = "make -B -C /etc/dotfiles nix-switch-theme NIX_THEME=light";
  };

  modules.shell.zsh.rc = ''
    # Helper to initialise a new Nix flake with direnv support with nixpkgs
    # codified to my current system version.
    nix-direnv-flake-init() {
      nix flake init -t github:nix-community/nix-direnv
      local sysnix=$(jq -r '.nodes.nixpkgs.locked.rev' /etc/dotfiles/flake.lock)
      sed -i 's/\/nixpkgs-unstable/\?rev='$sysnix'/' flake.nix
      echo "/.direnv" >> .gitignore
    }
  '';
}
