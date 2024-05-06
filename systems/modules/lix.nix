{ config, lib, ... }:
with lib;
let
  cfg = config.lix;
in
{
  options.lix = {
    enable = mkEnableOption "Enables Lix on the system instead of Nix";

    enableSpecialisation = mkEnableOption "Whether to isolate Lix into a separate nixos specialisation.";

    specialisationName = mkOption {
      type = types.str;
      default = "lix";
      description = lib.mDoc "The name of the nixos tag in the specialisation";
    };
  };

  config = mkIf cfg.enable {
    specialisation = mkIf cfg.enableSpecialisation {
      "${cfg.specialisationName}".configuration = {
        system.nixos.tags = [ cfg.specialisationName ];

        nix.settings.extra-substituters = [
          "https://cache.lix.systems"
        ];

        nix.settings.trusted-public-keys = [
          "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
        ];

        imports = [
          (import
            (
              (fetchTarball { url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz"; sha256 = "1qpgq280lsfiafq2sha8ln8jv7cdn4lfp3pjij9bqsmf369wdns3"; }) + "/module.nix"
            )
            {
              lix = fetchTarball { url = "https://git.lix.systems/lix-project/lix/archive/2.90-beta.1.tar.gz"; sha256 = "0d0dbn08pmrf7zlkihiyagcpy9ywdr14r6brqrjg47aqcjisaia4"; };
            }
          )
        ];
      };
    };
  };
}
