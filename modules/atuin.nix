{ ... }: {
  # Catppuccin Mocha theme for atuin (mauve accent)
  xdg.configFile."atuin/themes/catppuccin.toml".text = ''
    [theme]
    name = "catppuccin"

    [colors]
    # Alerts
    AlertInfo = "#a6e3a1"
    AlertWarn = "#fab387"
    AlertError = "#f38ba8"

    # Default text color (foreground)
    Base = "#cdd6f4"

    # Dimmed/muted text
    Guidance = "#9399b2"

    # Highlighted/important elements
    Important = "#f38ba8"

    # Annotations (time ago, duration)
    Annotation = "#cba6f7"

    # Title text
    Title = "#cba6f7"
  '';

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;

    flags = [
      "--disable-up-arrow"  # Keep up-arrow for zsh history search
    ];

    settings = {
      # UI style
      style = "compact";

      # Use catppuccin theme file
      theme.name = "catppuccin";
      # Sync settings
      auto_sync = false;
      sync_frequency = "0";
      update_check = false;

      # Search settings
      search_mode = "fuzzy";
      filter_mode = "global";
      filter_mode_shell_up_key_binding = "session";
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