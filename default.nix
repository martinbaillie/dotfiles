# Default configuration for all my uses of Nix (NixOS, Darwin).
{ config, pkgs, lib, options, ... }:
with builtins;
let
  inherit (lib) optional flatten;
  inherit (lib.systems.elaborate { system = currentSystem; }) isLinux isDarwin;
  pwd = toPath ./.;
in {
  imports = let theme = ./theme.nix;
  in flatten [
    # Configuration options.
    ./options.nix

    # Platform default.
    (optional isDarwin ./darwin-configuration.nix)
    (optional isLinux ./nixos-configuration.nix)

    # Current machine's theme (not version controlled).
    (optional (pathExists theme) (import theme))
  ];

  nix = let
    mkCache = url: key: { inherit url key; };
    cache = mkCache "https://cache.nixos.org"
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
    cachix = mkCache "https://cachix.cachix.org"
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM=";
    martinbaillie = mkCache "https://martinbaillie.cachix.org"
      "martinbaillie.cachix.org-1:nHT0c4/+UFDToxIVA6UoayUiNfaUA1SqFvZHeiYHVpo=";
    hercules-ci = mkCache "https://hercules-ci.cachix.org"
      "hercules-ci.cachix.org-1:ZZeDl9Va+xe9j+KqdzoBZMFJHVQ42Uu/c/1/KMC5Lw0=";
    all = [ cache cachix martinbaillie hercules-ci ];
  in {
    # Trusted binary caches.
    binaryCaches = map (x: x.url) all;
    binaryCachePublicKeys = map (x: x.key) all;

    # Add my custom setup to the default Nix expression search path.
    nixPath =
      [ "config=${pwd}/config" "bin=${pwd}/bin" "modules=${pwd}/modules" ]
      ++ options.nix.nixPath.default;
  };

  # Needs must.
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = import ./overlays.nix;

  my = {
    # Secrets.
    secrets = let path = ./.private/secrets.nix;
    in if pathExists path then import path else { };

    # Homedir.
    home.xdg = {
      enable = true;
      configFile."zsh/rc.d/rc.nix.zsh".text = ''
        alias nix-env="NIXPKGS_ALLOW_UNFREE=1 nix-env"
        alias nix-shell="NIXPKGS_ALLOW_UNFREE=1 nix-shell"
        alias nix-test="make -C ${pwd} test"
        alias nix-switch="make -C ${pwd} switch"
        alias nix-rollback="make -C ${pwd} switch --rollback"
        alias dark="make -B -C ${pwd} nix-switch-theme NIX_THEME=dark"
        alias light="make -B -C ${pwd} nix-switch-theme NIX_THEME=light"
      '';
    };
  };

  environment = {
    systemPackages = with pkgs; [ cachix ];
    variables = {
      # Set up Cachix.
      CACHIX_SIGNING_KEY = config.my.secrets.cachix_signing_key;

      # Force XDG defaults.
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_BIN_HOME = "$HOME/.local/bin";
      XDG_RUNTIME_DIR = "/run/user/$UID";
      PATH = "$XDG_BIN_HOME:$PATH";

      # Location, timezone and internationalisation.
      TZ = "Australia/Sydney";
      LC_ALL = "en_AU.UTF-8";
      LANG = "en_AU.UTF-8";
      LANGUAGE = "en_AU.UTF-8";
    };
  };
}
