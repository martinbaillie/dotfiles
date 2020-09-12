{ config, pkgs, lib, ... }:
with pkgs;
with import <home-manager/modules/lib/dag.nix> { inherit lib; };
let
  inherit (lib) mkMerge mkIf concatMapStrings concatStringsSep mapAttrsToList;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; })
    isDarwin isLinux;
  mkAuthorizedKeys = { runCommand }:
    runCommand "authorized_keys" {
      source = builtins.toFile "authorized_keys"
        (concatMapStrings builtins.readFile [
          <config/ssh/id_rsa.pub>
          <config/ssh/id_ed25519.pub>
        ]);
    } ''
      sed -s '$G' $source > $out
    '';
  envLines = mapAttrsToList (n: v: ''export ${n}="${v}"'') config.my.env;
in {
  my = mkMerge [
    {
      home = {
        home = {
          file = {
            ".ssh/id_rsa".text = config.my.secrets.id_rsa;
            ".ssh/id_rsa.pub".source = <config/ssh/id_rsa.pub>;
            ".ssh/id_ed25519".text = config.my.secrets.id_ed25519;
            ".ssh/id_ed25519.pub".source = <config/ssh/id_ed25519.pub>;
          };
          activation.authorizedKeys = dagEntryAfter [ "writeBoundary" ] ''
            install -D -m600 ${
              callPackage mkAuthorizedKeys { }
            } $HOME/.ssh/authorized_keys
          '';
        };
        xdg.configFile = {
          "zsh/rc.d/rc.fzy.zsh".source = <config/fzy/rc.zsh>;
          "zsh/rc.d/rc.fzf.zsh".source = <config/fzf/rc.zsh>;
          "zsh/rc.d/rc.term.zsh".text = ''
            alias mkdir='mkdir -p'
            alias cat='bat -p'
            alias wget='wget -c'
            alias bc='bc -lq'
            alias rg='rg --hidden'
            alias tree="tree -a -I '.git'"

            alias grep='grep --color=auto'
            alias fgrep='fgrep --color=auto'
            alias egrep='egrep --color=auto'

            alias exa='exa -h --group-directories-first --git'
            alias ls=exa
            alias l='exa -1a'
            alias ll='exa -la'
            alias lt='exa -lm -s modified'
          '';
          "zsh/rc.d/env.term.zsh".text = ''
            ${concatStringsSep "\n" envLines}
            ${config.my.init}
          '';
        };
      };

      packages = [
        age
        bat
        bc
        bfs
        binutils
        coreutils
        curl
        diffutils
        dnsutils
        entr
        exa
        fd
        file
        findutils
        fzf
        fzy
        gawk
        gettext
        gnuplot
        htop
        inetutils
        jq
        killall
        lastpass-cli
        lsof
        ncdu
        nmap
        perl
        sqlite
        stunnel
        tmux
        tree
        unzip
        wget
        xar
        yq-go
        zip

        (aspellWithDicts (d: with d; [ en en-computers en-science ]))
        (ripgrep.override { withPCRE2 = true; })
      ];
    }
    (mkIf isLinux { packages = [ psmisc ]; })
    (mkIf isDarwin { packages = [ unixtools.watch pstree ]; })
  ];
}
