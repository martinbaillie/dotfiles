{ lib, pkgs, ... }:

with pkgs;

let
  # installApplication pilfered from @jwiegley's dots.
  installApplication = { name, appname ? name, version, src, description
    , homepage, postInstall ? "", sourceRoot ? ".", ... }:
    with super;
    stdenv.mkDerivation {
      name = "${name}-${version}";
      version = "${version}";
      src = src;
      buildInputs = [ undmg unzip ];
      sourceRoot = sourceRoot;
      phases = [ "unpackPhase" "installPhase" ];
      installPhase = ''
        mkdir -p "$out/Applications/${appname}.app"
        cp -pR * "$out/Applications/${appname}.app"
      '' + postInstall;
      meta = with stdenv.lib; {
        description = description;
        homepage = homepage;
        maintainers = with maintainers; [ eqyiel ];
        platforms = platforms.darwin;
      };
    };
in rec {
  Emacs = callPackage ./emacs {
    inherit (darwin.apple_sdk.frameworks) AppKit GSS ImageIO;
    stdenv = clangStdenv;
  };

  Spectacle = installApplication rec {
    name = "Spectacle";
    version = "1.2";
    sourceRoot = "${name}.app";
    src = pkgs.fetchurl {
      url = "https://s3.amazonaws.com/spectacle/downloads/Spectacle+1.2.zip";
      sha256 = "037kayakprzvs27b50r260lwh2r9479f2pd221qmdv04nkrmnvbn";
    };
    description =
      "Window control with simple and customizable keyboard shortcuts";
    homepage = "https://www.spectacleapp.com";
  };

  # Redshift-style app for macOS that's still better than default NightShift.
  Flux = (installApplication rec {
    name = "f.lux";
    version = "40.1";
    sourceRoot = "Flux.app";
    src = pkgs.fetchurl {
      url = "https://justgetflux.com/mac/Flux.zip";
      sha256 = "0pgpzx4ilrzn4ppb1hb53sjyxckgq3v9jpj7qpiwyl5l35ak0i0q";
    };
    description = "Software to make your life better.";
    homepage = "https://justgetflux.com";
  });

  # TODO: Karabiner-Elements needs a kernel extension and I'm not sure how to
  # handle this in Nix.
  #
  # Once you remap CAPS to CTRL when held, ESC when tapped, you can never go back.
  # Karabiner-Elements = (installApplication rec {
  #   name = "Karabiner-Elements";
  #   version = "12.9.0";
  #   src = pkgs.fetchurl {
  #     url =
  #       "https://github.com/pqrs-org/Karabiner-Elements/releases/download/v12.9.0/Karabiner-Elements-12.9.0.dmg";
  #     #sha256 = "0bp69fp68bcljyq6jxkdf1mvpvzsb1davi3pddvbidy2zipdf7qf";
  #     sha256 = "1i1x05ypq3w6l5pmqcm80irj44v8w5yv91hr16lc9wch3d12gfsg";
  #   };
  #   description = "A powerful and stable keyboard customizer for macOS.";
  #   homepage = "https://pqrs.org/osx/karabiner";
  # }).overrideAttrs (attrs: {
  #   buildInputs = attrs.buildInputs ++ (with pkgs; [ xar cpio ]);
  #   unpackPhase = ''
  #     undmg < $src
  #     xar -xf Karabiner-Elements.sparkle_guided.pkg
  #     gunzip < Installer.pkg/Payload | cpio -i
  #   '';
  #   installPhase = ''
  #             mkdir -p $out/Applications
  #             mkdir -p $out/Library
  #             ls -lha
  #             ls -lha $out
  #             cp -pR Applications/* $out/Applications
  #             cp -pR Library/* $out/Library
  #     	#/sbin/kextload $out/Library/Application\ Support/org.pqrs/Karabiner-VirtualHIDDevice/Extensions/org.pqrs.driver.Karabiner.VirtualHIDDevice.*.kext
  #     	#launchctl load -F $out/Library/LaunchDaemons/org.pqrs.karabiner.karabiner_grabber.plist
  #     	#launchctl load -F $out/Library/LaunchDaemons/org.pqrs.karabiner.karabiner_observer.plist
  #     	#launchctl load -F $out/Library/LaunchAgents/org.pqrs.karabiner.karabiner_console_user_server.plist
  #           '';
  # });

}