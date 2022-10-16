{ lib, ... }:
let inherit (lib) mkOption types;
in
rec {
  mkOpt = type: default: mkOption { inherit type default; };

  mkOpt' = type: default: description:
    mkOption { inherit type default description; };

  mkBoolOpt = default:
    mkOption {
      inherit default;
      type = types.bool;
    };

  mkIntOpt = default:
    mkOption {
      inherit default;
      type = types.int;
    };

  mkStrOpt = default:
    mkOption {
      inherit default;
      type = types.str;
    };

  mkSecret = description: default:
    mkOption {
      inherit description default;
      type = with types; either str (listOf str);
    };
}
