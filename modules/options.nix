{ config, options, lib, home-manager, pkgs, ... }:
let inherit (lib.my) mkOpt mkOpt' mkSecret;
in
with lib; {
  options = with types; {
    dotfiles =
      let t = either str path;
      in
      {
        # Allow for dotfile location flexibility, defaulting to parent dir.
        dir = mkOpt t (findFirst pathExists (toString ../.)
          [ "${config.user.home}/.config/dotfiles" ]);
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

    secrets = {
      id_rsa = mkSecret "SSH RSA key" "";
      id_ed25519 = mkSecret "SSH ED25519 key" "";
      ssh_keygrips = mkSecret "SSH->GPG keygrips" [ ];
      gpg = mkSecret "GPG key" "";
      password = mkSecret "Local user password" "";
      cachix_signing_key = mkSecret "Cachix signing key" "";
      cachix_auth_token = mkSecret "Cachix auth token" "";
      work_overlay_url = mkSecret "$WORK Nix packages overlay URL" "";
      work_username = mkSecret "$WORK username" "";
      work_vcs_host = mkSecret "$WORK VCS host" "";
      work_vcs_path = mkSecret "$WORK VCS path" "";
      work_email = mkSecret "$WORK email" "";
      work_jira = mkSecret "$WORK JIRA instance" "";
      work_sourcegraph = mkSecret "$WORK Sourcegraph instance" "";
      exetel_username = mkSecret "Exetel username" "";
      exetel_password = mkSecret "Exetel password" "";
      protonvpn_username = mkSecret "ProtonVPN OpenVPN username" "";
      protonvpn_password = mkSecret "ProtonVPN OpenVPN password" "";
      openweathermap_api_key = mkSecret "OpenWeatherMap key" "";
      zuul_server_host = mkSecret "Zuul server host" "";
      zuul_server_port = mkSecret "Zuul server port" "";
      zuul_server_private_key = mkSecret "Zuul server private key" "";
      zuul_server_public_key = mkSecret "Zuul server public key" "";
      zuul_client_private_key = mkSecret "Zuul client private key" "";
      zuul_client_public_key = mkSecret "Zuul client public key" "";
      showrss_url = mkSecret "Show RSS URL" "";
    };

    # Elaborate the current system for convenience elsewhere.
    targetSystem =
      mkOpt' attrs (systems.elaborate { system = pkgs.stdenv.targetPlatform.system; })
        "Elaborated description of the target system";
  };

  config = {
    user =
      let
        user = builtins.getEnv "USER";
        name = if elem user [ "" "root" ] then "mbaillie" else user;
      in
      {
        inherit name;
        description = "Martin Baillie";
      } // optionalAttrs config.targetSystem.isLinux {
        uid = 1000;
        extraGroups = [ "wheel" ];
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

    # Secrets.
    # TODO: Evaluate `agenix` and other Nix store encryption options.
    secrets =
      let path = "${(builtins.getEnv "XDG_DATA_HOME")}/secrets.nix";
      in if pathExists path then import path else { };
  };
}
