# Defaults across my aarch64-based Darwin hosts.
{
    nixpkgs.hostPlatform = "aarch64-darwin";
  homebrew.brewPrefix = "/opt/homebrew/bin";
  env.PATH = [ "/opt/homebrew/bin" ];
}
