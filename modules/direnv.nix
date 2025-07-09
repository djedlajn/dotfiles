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
          "~/greenlight"
          "~/projects"
          "~/code"
        ];
      };
    };

    stdlib = ''
      # Use nix flake if flake.nix exists
      use_flake() {
        watch_file flake.nix
        watch_file flake.lock
        eval "$(nix print-dev-env --accept-flake-config)"
      }

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

      # Use asdf for version management
      use_asdf() {
        source_env "$(asdf direnv envrc)"
      }
    '';
  };
}
