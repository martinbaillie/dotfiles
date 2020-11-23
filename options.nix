{ config, options, lib, ... }:
with lib;
let
  mkOptionStr = value:
    mkOption {
      type = types.str;
      default = value;
    };
  mkSecret = description: default:
    mkOption {
      inherit description default;
      type = with types; either str (listOf str);
    };
in {
  # NOTE: options attributes inspired by @hlissner's dots.

  # Personal.
  options.my.username = mkOptionStr "martin";
  options.my.fullname = mkOptionStr "Martin Baillie";
  options.my.email = mkOptionStr "martin@baillie.id";

  # Secrets.
  options.my.secrets = {
    id_rsa = mkSecret "SSH RSA key." "";
    id_ed25519 = mkSecret "SSH ED25519 key." "";
    ssh_keygrips = mkSecret "SSH->GPG keygrips." [ ];
    gpg = mkSecret "GPG key." "";
    password = mkSecret "Local user password." "";
    cachix_signing_key = mkSecret "Cachix signing key." "";
    work_overlay_url = mkSecret "$WORK Nix packages overlay URL." "";
    work_username = mkSecret "$WORK username." "";
    work_vcs_host = mkSecret "$WORK VCS host." "";
    work_vcs_path = mkSecret "$WORK VCS path." "";
    work_email = mkSecret "$WORK email." "";
    protonvpn_username = mkSecret "ProtonVPN OpenVPN username." "";
    protonvpn_password = mkSecret "ProtonVPN OpenVPN password." "";
    zuul_server_host = mkSecret "Zuul server host" "";
    zuul_server_port = mkSecret "Zuul server port" "";
    zuul_server_private_key = mkSecret "Zuul server private key" "";
    zuul_server_public_key = mkSecret "Zuul server public key" "";
    zuul_client_private_key = mkSecret "Zuul client private key" "";
    zuul_client_public_key = mkSecret "Zuul client public key" "";
  };

  # Convenience aliases.
  options.my.home =
    mkOption { type = options.home-manager.users.type.functor.wrapped; };
  config.home-manager.users.${config.my.username} =
    mkAliasDefinitions options.my.home;

  options.my.user =
    mkOption { type = options.users.users.type.functor.wrapped; };
  config.users.users.${config.my.username} = mkAliasDefinitions options.my.user;

  options.my.packages = mkOption {
    type = types.listOf types.package;
    description = "The set of packages to appear in the user environment.";
  };
  config.my.user.packages = config.my.packages;

  # Shell and environment.
  options.my.env = mkOption {
    type = with types;
      attrsOf (either (either str path) (listOf (either str path)));
    apply = mapAttrs (n: v:
      if isList v then
        concatMapStringsSep ":" (x: toString x) v
      else
        (toString v));
  };
  options.my.init = mkOption {
    type = types.lines;
    description = ''
      An init script that runs after the environment has been rebuilt or
      booted. Anything done here should be idempotent and inexpensive.
    '';
    default = "";
  };

  # Build an OS-level customised environment.
  config.environment.extraInit = let
    exportLines = mapAttrsToList (n: v: ''export ${n}="${v}"'') config.my.env;
  in ''
    ${concatStringsSep "\n" exportLines}
    ${config.my.init}
  '';

  # Darwin.
  options.my.casks = mkOption {
    type = with types; nullOr (listOf str);
    description = ''
      Homebrew casks to install on the macOS/Darwin system.
    '';
  };
}
