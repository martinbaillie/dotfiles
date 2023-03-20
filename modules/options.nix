{ config, options, lib, home-manager, pkgs, ... }:
with lib;
with builtins;
let
  inherit (lib.my) mkOpt mkOpt' mkPrivate;
  user = getEnv "USER";
  name = if elem user [ "" "root" ] then "mbaillie" else user;
in
{
  options = with types; {
    dotfiles =
      let t = either str path;
      in
      {
        # Allow for dotfile location flexibility, defaulting to parent dir.
        dir = mkOpt t (findFirst pathExists (toString ../.)
          [ "${config.user.home}/.config/dotfiles" "/etc/dotfiles" ]);
        configDir = mkOpt t "${config.dotfiles.dir}/config";
        modulesDir = mkOpt t "${config.dotfiles.dir}/modules";
        privateDir = mkOpt t "${config.dotfiles.dir}/.private";
        themesDir = mkOpt t "${config.dotfiles.modulesDir}/themes";
      };

    home = {
      file = mkOpt' attrs { } "Files to place directly in $HOME";
      configFile = mkOpt' attrs { } "Files to place in $XDG_CONFIG_HOME";
      dataFile = mkOpt' attrs { } "Files to place in $XDG_DATA_HOME";
      defaultApplications = mkOpt' attrs { } "XDG/MIME default applications";
      services = mkOpt' attrs { } "Home-manager provided user services";
      programs = mkOpt' attrs { } "Home-manager provided programs";
      activation = mkOpt' attrs { } "Home-manager provided activation";
    };

    user = mkOpt' attrs { } "Primary user management";

    env = mkOption {
      type = attrsOf (oneOf [ str path (listOf (either str path)) ]);
      apply = mapAttrs (n: v:
        # Handle an array of items separated by `:` e.g. PATH.
        if isList v then
          concatMapStringsSep ":" (x: toString x) v
        else
          (toString v));
      default = { };
      description = "Global environment variables";
    };

    private = {
      work_overlay_url = mkPrivate "$WORK Nix packages overlay URL" "";
      work_username = mkPrivate "$WORK username" "";
      work_vcs_host = mkPrivate "$WORK VCS host" "";
      work_vcs_path = mkPrivate "$WORK VCS path" "";
      work_email = mkPrivate "$WORK email" "";
      work_jira = mkPrivate "$WORK JIRA instance" "";
      work_sourcegraph = mkPrivate "$WORK Sourcegraph instance" "";
      showrss_url = mkPrivate "Show RSS URL" "";
    };

    # Elaborate the current system for convenience elsewhere.
    targetSystem =
      mkOpt' attrs (systems.elaborate { system = pkgs.stdenv.targetPlatform.system; })
        "Elaborated description of the target system";
  };

  config = {
    user =
      {
        inherit name;
        description = "Martin Baillie";
        packages = with pkgs; [ sops ssh-to-age ];
      } // optionalAttrs config.targetSystem.isLinux {
        extraGroups = [ "wheel" "autologin" ];
        group = "users";
        home = "/home/${name}";
        isNormalUser = true;
      }
      // optionalAttrs config.targetSystem.isDarwin { home = "/Users/${name}"; };

    users.users.${config.user.name} = mkAliasDefinitions options.user;
    nix =
      let users = [ "root" config.user.name ];
      in
      {
        settings =
          {
            trusted-users = users;
            allowed-users = users;
          };
      };

    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;
      verbose = false;
      # NOTE: Home-manager shortened maps are as follows:
      # home.file        ->  home-manager.users.<user>.home.file
      # home.configFile  ->  home-manager.users.<user>.home.xdg.configFile
      # home.dataFile    ->  home-manager.users.<user>.home.xdg.dataFile
      # home.services    ->  home-manager.users.<user>.home.services
      # home.programs    ->  home-manager.users.<user>.home.programs
      users.${config.user.name} = {
        home = {
          file = mkAliasDefinitions options.home.file;
          activation = mkAliasDefinitions options.home.activation;
          stateVersion = "21.11";
        };
        xdg = {
          enable = true;
          configFile = mkAliasDefinitions options.home.configFile;
          dataFile = mkAliasDefinitions options.home.dataFile;
        } // optionalAttrs config.targetSystem.isLinux {
          userDirs = {
            enable = true;
            createDirectories = true;
          };
          mime.enable = true;
          mimeApps = {
            enable = true;
            defaultApplications =
              mkAliasDefinitions options.home.defaultApplications;
          };
        };
        services = mkAliasDefinitions options.home.services;
        programs = mkAliasDefinitions options.home.programs;
      };
    };

    # Ensure any existing PATH managed outside of Nix gets respected.
    env.PATH = [ "$PATH" ];

    # Merge Nix environment variables declared by modules.
    environment.extraInit = concatStringsSep "\n"
      (mapAttrsToList (n: v: ''export ${n}="${v}"'') config.env);

    # Private expressions and secrets.
    private = import "${config.dotfiles.privateDir}/private.nix";

    sops = {
      defaultSopsFile = /etc/dotfiles/.private/secrets.age.yaml;
      age.keyFile = "${config.home-manager.users.${config.user.name}.xdg.dataHome}/keys.txt";
      secrets =
        let
          owner = config.user.name;
          group = if config.targetSystem.isDarwin then "staff" else "users";
          genSecret = name: {
            inherit name;
            value = {
              inherit owner group;
              path = "${config.my.xdg.dataHome}/secrets/${name}";
            };
          };
        in
        listToAttrs
          (map genSecret [
            "id_rsa"
            "id_ed25519"
            "gpg"
            "cachix_signing_key"
            "cachix_auth_token"
            "openweathermap_api_key"
          ]) //
        {
          cachix_dhall = {
            inherit owner group;
            path = "${config.my.xdg.configHome}/cachix/cachix.dhall";
          };
        } // optionalAttrs config.targetSystem.isLinux {
          password = { neededForUsers = true; };
        };
    };

    env.SOPS_AGE_KEY_FILE = config.sops.age.keyFile;
  };

  imports = [
    # Some more shortened module aliases.
    (mkAliasOptionModule [ "my" ] [ "home-manager" "users" "${name}" ])
    (mkAliasOptionModule [ "secrets" ] [ "sops" "secrets" ])
  ];
}
