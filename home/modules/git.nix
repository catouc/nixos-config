{ pkgs, config, lib, ... }:
let
  cfg = config.pb.home.git;

  urlRewritesOptionType = { ... }: {
    options = {
      from = lib.mkOption {
        type = lib.types.str;
        description = lib.literalExpression "The URL pattern we want to rewrite";
        example = lib.literalExpression "https://github.com";
      };

      to = lib.mkOption {
        type = lib.types.str;
        description = lib.literalExpression "The URL we want `from` to be written into";
        example = lib.literalExpression "ssh://git@github.com";
      };
    };
  };
in
{
  options.pb.home.git = {
    enable = lib.mkEnableOption "Enable git configuration";

    email = lib.mkOption {
      type = lib.types.str;
    };

    urlRewrites = lib.mkOption {
      type = lib.types.listOf (lib.types.submoduleWith {
        modules = [
          urlRewritesOptionType
        ];
      });
      default = {};
    };
  };

  config = lib.mkIf cfg.enable {
    home.shellAliases = {
      gs = "git status";
      gp = "git push";
      gpu = "git push -u origin $(git rev-parse --abbrev-ref HEAD)";
      gpum = "git push -u origin $(git rev-parse --abbrev-ref HEAD) -o merge_request.create";
    };
    programs.git = {
      enable = true;
      userName = "Philipp Böschen";
      userEmail = cfg.email;

      aliases = {
        tree = "log --graph --decorate --oneline --abbrev-commit";
      };

      extraConfig = {
        core = {
          pager = "delta";
        };

        interactive = {
          diffFilter = "delta --color-only";
        };

        delta = {
          navigate = true;
          light = false;
        };

        merge = {
          conflictstyle = "diff3";
        };

        diff = {
          colorMoved = "default";
        };

        init = {
          defaultBranch = "main";
        };

        pull = {
          rebase = true;
        };

        push = {
          autoSetupRemote = true;
        };

        # https://noogle.dev/f/builtins/mapAttrs
        url = lib.listToAttrs (lib.map (rewrite: {
          name = "${rewrite.to}";
          value = {
            insteadOf = "${rewrite.from}";
          };
        }) cfg.urlRewrites);
      };
    };
  };
}
