{ ... }: {
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;

    config = {
      global = {
        load_dotenv = true;
        strict_env = false;
        warn_timeout = "30s";
      };
      whitelist = {
        prefix = [
          "~/projects"
          "~/code"
          "~/xsolis"
        ];
      };
    };

    stdlib = ''
      # NOTE: no custom use_flake here — direnv sources lib/*.sh before
      # direnvrc, so defining one would shadow nix-direnv's use_flake and
      # silently disable its eval caching and GC-root pinning.

      # Layout for node projects
      layout_node() {
        PATH_add node_modules/.bin
      }

      # Layout for Python projects with venv
      layout_python_venv() {
        local python=''${1:-python3}
        unset PYTHONHOME
        if [[ ! -d .venv ]]; then
          $python -m venv .venv
        fi
        source .venv/bin/activate
      }

      # Use mise/rtx for version management
      use_mise() {
        direnv_load mise direnv exec
      }
    '';
  };
}
