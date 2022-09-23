{ pkgs, lib, inputs, config, ... }:
# TODO: Move outside of Zuul host.
let network = {
  domain = "baillie.id";
  nodes = [
    { name = "betsy"; ip = "10.0.1.5"; mac = "28:7f:cf:53:79:6f"; }
    { name = "betsy"; ip = "10.0.1.5"; mac = "f8:75:a4:1c:c0:38"; }
    { name = "bebek"; ip = "10.0.1.6"; mac = ""; }
  ];
};
in
{
  imports = [
    inputs.nixos-hardware.nixosModules.pcengines-apu
  ];

  # TODO: Do I care about this being in /etc/hosts? Could just be in Unbound.
  networking.stevenBlackHosts = {
    enable = true;
    blockFakenews = true;
    blockGambling = true;
  };

  ##############################################################
  # TEMP:
  users.users.root.password = lib.mkForce "nixos";
  services.openssh = {
    permitRootLogin = lib.mkForce "yes";
    passwordAuthentication = lib.mkForce true;
  };
  services.getty.autologinUser = lib.mkForce "root";
  ##############################################################

  modules = {
    editors = {
      vim.enable = true;
      default = "vim";
    };

    services = { ssh.enable = true; };

    shell = {
      enable = true;

      git.enable = true;
      gnupg.enable = true;
      ssh.enable = true;
      zsh.enable = true;
    };
  };

  boot = {
    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/sda";
    };

    kernel.sysctl = {
      # IP forwarding.
      "net.ipv4.conf.all.forwarding" = 1;
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;

      "net.ipv6.conf.all.accept_ra" = 0;
      "net.ipv6.conf.all.autoconf" = 0;
      "net.ipv6.conf.all.use_tempaddr" = 0;

      # Disable netfilter for bridges.
      # NOTE: means bridge-routed frames do not go through iptables
      # https://bugzilla.redhat.com/show_bug.cgi?id=512206#c0
      "net.bridge.bridge-nf-call-ip6tables" = 0;
      "net.bridge.bridge-nf-call-iptables" = 0;
      "net.bridge.bridge-nf-call-arptables" = 0;
    };
  };

  networking = {
    domain = network.domain;
    search = [ network.domain ];

    vlans = {
      # Internet ingress/egress.
      wan = {
        id = 10;
        interface = "enp1s0";
      };

      # Trusted, free-roam personal devices.
      lan = {
        id = 20;
        interface = "enp2s0";
      };

      # Untrusted, locked-down IoT devices.
      iot = {
        id = 30;
        interface = "enp2s0";
      };
    };

    # The global useDHCP flag is deprecated, therefore explicitly set to false
    # here. Per-interface useDHCP will be mandatory in the future, so this
    # generated config replicates the default behaviour.
    useDHCP = false;
    interfaces = {
      enp1s0.useDHCP = true; # TODO: GOLIVE Don't request DHCP on the physical interfaces.
      enp2s0.useDHCP = false;
      enp3s0.useDHCP = false;

      wan.useDHCP = false;
      lan = {
        ipv4.addresses = [{
          address = "10.1.1.1";
          prefixLength = 24;
        }];
      };
      iot = {
        ipv4.addresses = [{
          address = "10.1.254.1";
          prefixLength = 24;
        }];
      };
    };

    # Use modern nftables for firewalling.
    nat.enable = false;
    firewall.enable = false;
    nftables = {
      enable = true;


    };
  };

  services.pppd = {
    enable = true;
    peers = {
# exetel = {
#         enable = false; # TODO: GOLIVE.
#         autostart = true;
#         config = ''
#           plugin rp-pppoe.so wan
# 
#           name "${config.secrets.exetel_username}"
#           password "${config.secrets.exetel_password}"
# 
#           persist
#           maxfail 0
#           holdoff 5
# 
#           noipdefault
#           defaultroute
#         '';
#       };
    };
  };

  # TODO Relocate to own service
  boot.kernel.sysctl = {
    "net.core.rmem_default" = 31457280;
    "net.core.wmem_default" = 31457280;
    "net.core.rmem_max" = 2147483647;
    "net.core.wmem_max" = 2147483647;
  };
  services.unbound = {
    enable = true;
    localControlSocketPath = "/run/unbound/unbound.ctl";
    settings = {
      server =
        let
          # Make the bad hosts list compaible with Unbound.
          badhosts = with pkgs; with inputs; runCommand "badhosts.db" { } ''
            ${gnugrep}/bin/grep '^0\.0\.0\.0' ${bad-hosts}/alternates/fakenews-gambling-porn/hosts | \
            ${gawk}/bin/awk '{print "local-zone: \""$2"\" redirect\nlocal-data: \""$2" A 0.0.0.0\""}' > $out
          '';
        in
        {
          # TODO: use `network.nix` for IPs.
          interface = [ "127.0.0.1" ];
          access-control = [
            "127.0.0.0/8 allow"
          ]
          ++ map (a: "${a.address}/${toString a.prefixLength} allow")
            config.networking.interfaces.lan.ipv4.addresses
          ++ map (a: "${a.address}/${toString a.prefixLength} allow")
            config.networking.interfaces.iot.ipv4.addresses;

          # Ensure privacy of local IP (RFC1918) ranges.
          private-address = [
            "192.168.0.0/16"
            "169.254.0.0/16"
            "172.16.0.0/12"
            "10.0.0.0/8"
            "fd00::/8"
            "fe80::/10"
          ];

          log-queries = true;
          statistics-interval = 0;
          extended-statistics = true;
          statistics-cumulative = true;

          domain-insecure = true;
          private-domain = "baillie.id";
          tls-cert-bundle = "/etc/ssl/certs/ca-certificates.crt";

          # Perform prefetching of close to expired message cache entries. This
          # only applies to domains that have been frequently queried.
          prefetch = true;

          # Ensure kernel buffers are large enough to not lose messages in
          # heavy traffic.
          so-rcvbuf = "4m";
          so-reuseport = true;
          so-sndbuf = "4m";

          hide-identity = true;
          hide-version = true;

          local-zone = map (node: ''"${node.name}.${network.domain}." redirect'')
            network.nodes;
          local-data = map (node: ''"${node.name}.${network.domain}. A ${node.ip}"'')
            network.nodes;

          include = [ (toString badhosts) ];
        };
      forward-zone = [
        {
          name = ".";
          forward-addr = [
            "1.1.1.1@853#cloudflare-dns.com"
            "1.0.0.1@853#cloudflare-dns.com"
          ];
          forward-ssl-upstream = true;
        }
      ];
      remote-control = {
        control-enable = true;
        control-use-cert = false;
      };
    };
  };
}
