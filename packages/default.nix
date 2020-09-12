{ lib, pkgs, ... }:

with pkgs;

let
  inherit (stdenv) isDarwin;
  inherit (lib) optionals optionalString;

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
        maintainers = with maintainers; [ mbaillie ];
        platforms = platforms.darwin;
      };
    };
in rec {
  # My custom Emacs 28 native comp builds for macOS and NixOS (+Wayland).
  # Emacs = emacsGcc.overrideAttrs (old: rec {
  #
  # Native comp currently bust on macOS.
  # REVIEW: https://github.com/NixOS/nixpkgs/pull/94637
  Emacs = emacsGit.overrideAttrs (old: rec {
    name = "emacs-git-${version}";
    version = "20200706.0";

    src = fetchFromGitHub {
      owner = "emacs-mirror";
      repo = "emacs";
      rev = "1a99697b4d8c11a10d5e6a306103740d92cc08a1"; # 06/08/20
      sha256 = "1n92fbn9y0bcc08rss8jyv4m3wkww7gglg6p49gz0k05rj6yxmbv";
    };

    # Work laptop OS version is still pinned to Mojave but these headers are
    # present in userspace.
    preConfigure = optionalString isDarwin ''
      export ac_cv_func_aligned_alloc=no
    '';

    patches = [
      ./emacs/patches/clean-env.patch
      ./emacs/patches/optional-org-gnus.patch
    ] ++ (optionals isDarwin [
      ./emacs/patches/at-fdcwd.patch
      ./emacs/patches/fix-window-role.patch
      ./emacs/patches/no-frame-refocus.patch
      # I'm not using Yabai anymore.
      # ./emacs/patches/no-titlebar.patch
    ]);
  });

  EmacsWayland = enableDebugging (emacs.overrideAttrs ({ buildInputs
    , nativeBuildInputs ? [ ], postPatch ? "", configureFlags ? [ ], ... }:
    let
      pname = "emacs-pgtk";
      version = "28.0.50";
    in {
      name = "${pname}-${version}";
      src = fetchFromGitHub {
        owner = "masm11";
        repo = "emacs";
        rev = "c6ff556f390e5e573d5d0c4fb3a2da54a0a433dc"; # 26/05/20.
        sha256 = "10m40qpvnbxy98h84lvlp1f5zpqqarbxihjn7x1v4072hf2fhj3q";
      };
      patches = [ ];
      buildInputs = buildInputs ++ [ wayland wayland-protocols ];
      nativeBuildInputs = nativeBuildInputs ++ [ autoreconfHook texinfo ];
      configureFlags = configureFlags
        ++ [ "--without-x" "--with-cairo" "--with-modules" ];
    }));

  # Predictable Firefox for Darwin, controllable with home-manager.
  Firefox = installApplication rec {
    name = "Firefox";
    version = "80.0";
    sourceRoot = "${name}.app";
    src = pkgs.fetchurl {
      name = "Firefox-${version}.dmg";
      url =
        "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${version}/mac/en-GB/Firefox%20${version}.dmg";
      sha256 = "1slxg3s2ywbs0mkcayk5b6nh9dw9jzwc4bswggv32zligmbh157n";
    };
    description =
      "Firefox, is a free and open-source web browser developed by the Mozilla Foundation";
    homepage = "https://www.mozilla.org/en-US/exp/firefox";
  };

  # Simplistic window snapping in lieu of a proper tiling WM like Yabai.
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
