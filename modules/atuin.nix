{ ... }: {
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;

    # Atuin owns Ctrl+R; fzf's history widget is disabled in the fzf module
    flags = [
      "--disable-up-arrow" # Keep up-arrow for zsh history search
    ];

    # Shell hooks hand history to a long-lived daemon (which also runs the
    # background sync) instead of opening the SQLite DB per command. The HM
    # module sets settings.daemon.enabled + socket_path and installs a launchd
    # agent, so neither is repeated here.
    daemon.enable = true;

    # Catppuccin Mocha theme (mauve accent)
    themes.catppuccin = {
      theme.name = "catppuccin";
      colors = {
        # Alerts
        AlertInfo = "#a6e3a1";
        AlertWarn = "#fab387";
        AlertError = "#f38ba8";
        # Default text color (foreground)
        Base = "#cdd6f4";
        # Dimmed/muted text
        Guidance = "#9399b2";
        # Highlighted/important elements
        Important = "#f38ba8";
        # Annotations (time ago, duration)
        Annotation = "#cba6f7";
        # Title text
        Title = "#cba6f7";
      };
    };

    settings = {
      # UI style
      style = "compact";

      # Use the catppuccin theme declared above
      theme.name = "catppuccin";
      # Sync settings — atuin server on cc-remote (nixos/atuin.nix in
      # the dev-remote repo), tailnet-only :8889. E2E encrypted.
      auto_sync = true;
      sync_frequency = "5m";
      sync_address = "http://cc-remote:8889";
      sync.records = true;
      update_check = false;

      # Search settings
      search_mode = "fuzzy";
      filter_mode = "global";
      inline_height = 25;
      show_preview = true;
      show_help = true;
      exit_mode = "return-original";

      # History settings
      history_filter = [
        "^export "
        "^AWS_"
        "^TOKEN"
        "^SECRET"
        "^PASSWORD"
        "^PASS="
        "^KEY="
      ];
      secrets_filter = true;
      enter_accept = true;

      # Stats - track subcommands for common tools
      stats = {
        common_subcommands = [
          "cargo"
          "docker"
          "git"
          "go"
          "kubectl"
          "nix"
          "npm"
          "pnpm"
          "yarn"
          "mix"
          "iex"
        ];
        common_prefix = [ "sudo" ];
      };

      # Keys
      keys = {
        scroll_exits = true;
      };
    };
  };
}
