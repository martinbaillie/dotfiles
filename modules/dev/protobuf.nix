{ config, lib, pkgs, options, ... }:
with lib;
let cfg = config.modules.dev.protobuf;
in
{
  options.modules.dev.protobuf = {
    enable = my.mkBoolOpt false;
    grpc.enable = my.mkBoolOpt false;
  };

  config = mkIf cfg.enable (mkMerge [
    (if (builtins.hasAttr "homebrew" options) then {
      homebrew.casks = [ "insomnia" "postman" ];
    } else {
      user.packages = with pkgs; [ insomnia postman ];
    })
    {
      user.packages = with pkgs; [ grpcurl ];
    }
  ]);
}
