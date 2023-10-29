{
  description = "Martin Baillie's 99p Flake";
  inputs = {
    nixpkgs.url = "nixpkgs/release-23.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    # Declarative user home management.
    home-manager.url = github:rycee/home-manager/release-23.05;
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Declarative, NixOS-style configuration but for macOS.
    darwin.url = github:lnl7/nix-darwin/master;
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Block adservers, fake news etc.
    bad-hosts.url = github:StevenBlack/hosts;
    bad-hosts.inputs.nixpkgs.follows = "nixpkgs";

    # Secrets.
    sops-nix.url = github:4825764518/sops-nix/darwin;
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Emacs overlays.
    emacs-overlay.url = github:nix-community/emacs-overlay;
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";
    emacs-macos = {
      type = "github";
      owner = "tyler-dodge";
      repo = "emacs";
      ref = "tyler-main-emacs-29";
      flake = false;
    };

    # Vale styles.
    vale-Google.flake = false;
    vale-Google.url = github:errata-ai/Google;
    vale-Microsoft.flake = false;
    vale-Microsoft.url = github:errata-ai/Microsoft;
    vale-Joblint.flake = false;
    vale-Joblint.url = github:errata-ai/Joblint;
    vale-alex.flake = false;
    vale-alex.url = github:errata-ai/alex;
    vale-proselint.flake = false;
    vale-proselint.url = github:errata-ai/proselint;
    vale-write-good.flake = false;
    vale-write-good.url = github:errata-ai/write-good;

    # NixOS hardware definitions.
    nixos-hardware.url = github:nixos/nixos-hardware;

    # Firefox Darwin overlay.
    firefox-darwin.url = github:bandithedoge/nixpkgs-firefox-darwin;
    firefox-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Zgenom zsh package manager.
    zgenom.flake = false;
    zgenom.url = github:jandamm/zgenom;

    # Tridactyl themes.
    base16-tridactyl.flake = false;
    base16-tridactyl.url = github:martinbaillie/base16-tridactyl;
  };

  # NOTE: Flake interface found at:
  # https://github.com/NixOS/nix/blob/master/src/nix/flake.cc
  outputs =
    inputs@{ self
    , nixpkgs
    , nixpkgs-unstable
    , darwin
    , bad-hosts
    , emacs-overlay
    , firefox-darwin
    , ...
    }:
    let
      inherit (lib) genAttrs;
      inherit (lib.my) mapModules mapModulesRec mapHosts mapConfigurations;

      supportedSystems = rec {
        darwin = [ "x86_64-darwin" "aarch64-darwin" ];
        linux = [ "x86_64-linux" "aarch64-linux" ];
        all = darwin ++ linux;
      };

      mkPkgs = pkgs: extraOverlays: system:
        import pkgs {
          inherit system;
          overlays = extraOverlays ++ (lib.attrValues self.overlays);
        };

      rosettaOverlay = new: old:
        let
          isAppleSilicon = with old.stdenv.hostPlatform; isDarwin && isAarch64;
          intelPkgs = nixpkgs.legacyPackages.x86_64-darwin;
        in
        (lib.optionalAttrs isAppleSilicon {
          # FIXME: These are all currently broken on aarch64.
          inherit (intelPkgs)
            # wireshark: just broken everywhere due to LLVM.
            ssm-session-manager-plugin; # Waiting on AWS to fix upstream.
        });

      pkgs = genAttrs supportedSystems.all
        (mkPkgs nixpkgs [ emacs-overlay.overlay self.overlay rosettaOverlay firefox-darwin.overlay ]);
      pkgsUnstable =
        genAttrs supportedSystems.all (mkPkgs nixpkgs-unstable [ ]);

      lib = nixpkgs.lib.extend (self: super: {
        my = import ./lib {
          inherit pkgs inputs darwin;
          lib = self;
        };
      });
    in
    {
      lib = lib.my;

      # Default modules usable in dependant flakes.
      nixosModules = {
        dotfiles = import ./.;
      } // mapModulesRec ./modules import;

      darwinModules = {
        dotfiles = import ./.;
      } // mapModulesRec ./modules import;

      # Default overlays usable in dependant flakes.
      overlay = _:
        { system, ... }: {
          unstable = pkgsUnstable.${system};
          my = self.packages.${system};
        };
      overlays = mapModules ./overlays import;

      packages =
        let
          mkPackages = system:
            mapModules ./packages (p: pkgs.${system}.callPackage p { });
        in
        genAttrs supportedSystems.all mkPackages;

      # `nix develop`.
      devShell =
        let forAllSupportedSystems = f: genAttrs supportedSystems.all (s: f s);
        in
        forAllSupportedSystems
          (system: with pkgs.${system}; import ./shell.nix { inherit pkgs; });

      # Nix Darwin host configurations.
      darwinConfigurations =
        mapConfigurations supportedSystems.darwin ./hosts/darwin;

      # NixOS host configurations.
      nixosConfigurations =
        mapConfigurations supportedSystems.linux ./hosts/linux;
    };
}
