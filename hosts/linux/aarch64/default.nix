# Defaults across my aarch64-based Linux hosts.
{ config, lib, pkgs, ... }:

{
    nixpkgs.hostPlatform = "aarch64-linux";
}

