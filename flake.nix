{
  description = "Martin Baillie's 99p Flake";
  inputs = {
    # Flakes mostly forces us to live on the edge at the moment.
    nixpkgs.url = "nixpkgs/nixos-unstable";

    # Which shifts my traditional unstable to _really_ unstable.
    nixpkgs-unstable.url = "nixpkgs/master";

    # Declarative, NixOS-style configuration but for macOS.
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Declarative user home management.
    home-manager.url = "github:rycee/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Miscellaneous overlays.
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    # TODO: pin "github:nix-community/emacs-overlay?rev=67fe74d6e73e3c8a983b09a76d809acc730ad911";

    # Hardware definitions.
    nixos-hardware.url = "github:nixos/nixos-hardware";
  };

  # NOTE: Flake interface found at:
  # https://github.com/NixOS/nix/blob/master/src/nix/flake.cc
  outputs =
    inputs@{ self, nixpkgs, nixpkgs-unstable, darwin, emacs-overlay, ... }:
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
        in (lib.optionalAttrs isAppleSilicon {
          # FIXME: These are all currently broken on aarch64.
          inherit (intelPkgs)
          # wireshark: just broken everywhere due to LLVM.
            ssm-session-manager-plugin; # Waiting on AWS to fix upstream.
        });

      pkgs = genAttrs supportedSystems.all
        (mkPkgs nixpkgs [ emacs-overlay.overlay self.overlay rosettaOverlay ]);
      pkgsUnstable =
        genAttrs supportedSystems.all (mkPkgs nixpkgs-unstable [ ]);

      lib = nixpkgs.lib.extend (self: super: {
        my = import ./lib {
          inherit pkgs inputs darwin;
          lib = self;
        };
      });
    in {
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

      packages = let
        mkPackages = system:
          mapModules ./packages (p: pkgs.${system}.callPackage p { });
      in genAttrs supportedSystems.all mkPackages;

      # NixOS host configurations.
      nixosConfigurations =
        mapConfigurations supportedSystems.linux ./hosts/linux;

      # Nix Darwin host configurations.
      darwinConfigurations =
        mapConfigurations supportedSystems.darwin ./hosts/darwin;

      # `nix develop`.
      devShell =
        let forAllSupportedSystems = f: genAttrs supportedSystems.all (s: f s);
        in forAllSupportedSystems
        (system: with pkgs.${system}; import ./shell.nix { inherit pkgs; });
    };
}
