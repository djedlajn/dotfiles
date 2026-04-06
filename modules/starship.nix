# Starship prompt configuration
{ config, ... }: {
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableTransience = true;

    settings = {
      add_newline = false;

      # Left: prompt + dir + git | Right: versions
      format = "$nix_shell$character$directory$git_branch$git_status";
      right_format = "$nodejs$bun$java$kotlin$rust$golang$python$package";

      # ─────────────────────────────────────────────────────────────
      # Prompt character
      # ─────────────────────────────────────────────────────────────
      character = {
        success_symbol = "[󱍢](bold green)";
        error_symbol = "[󱍢](bold red)";
        vimcmd_symbol = "[󱍢](bold yellow)";
      };

      # ─────────────────────────────────────────────────────────────
      # Directory
      # ─────────────────────────────────────────────────────────────
      directory = {
        truncation_length = 3;
        truncation_symbol = "…/";
        style = "bold blue";
        format = "[ $path]($style) ";  # nf-fa-folder_open
      };

      # ─────────────────────────────────────────────────────────────
      # Git
      # ─────────────────────────────────────────────────────────────
      git_branch = {
        format = "[ $branch]($style) ";  # nf-dev-git_branch
        style = "bold mauve";
        truncation_symbol = "…";
        truncation_length = 20;
      };

      git_status = {
        format = "[$all_status$ahead_behind]($style) ";
        style = "bold yellow";
        ahead = "⇡$count ";
        behind = "⇣$count ";
        diverged = "⇕ ";
        conflicted = "✖ ";
        untracked = "? ";
        stashed = "≡ ";
        modified = "! ";
        staged = "+ ";
        renamed = "» ";
        deleted = "✕ ";
      };

      # ─────────────────────────────────────────────────────────────
      # Languages - with nf-dev icons
      # ─────────────────────────────────────────────────────────────
      nodejs = {
        format = "[ $version](bold green) ";  # nf-dev-nodejs
        detect_files = [ "package-lock.json" "yarn.lock" "package.json" ];
        detect_folders = [ "node_modules" ];
      };

      bun = {
        format = "[ $version](bold peach) ";
        detect_files = [ "bun.lock" "bunfig.toml" ];
      };

      java = {
        format = "[ $version](bold red) ";  # nf-dev-java
      };

      kotlin = {
        format = "[ $version](bold mauve) ";
      };

      rust = {
        format = "[ $version](bold peach) ";  # nf-dev-rust
      };

      golang = {
        format = "[ $version](bold sky) ";  # nf-dev-go
      };

      python = {
        format = "[ $version](bold yellow) ";  # nf-dev-python
      };

      package = {
        format = "[ $version](dimmed) ";  # nf-oct-package
      };

      # ─────────────────────────────────────────────────────────────
      # Nix shell
      # ─────────────────────────────────────────────────────────────
      nix_shell = {
        format = "[󱄅 $state]($style) ";  # nf-linux-nixos
        style = "bold sky";
      };

      # ─────────────────────────────────────────────────────────────
      # Disabled modules
      # ─────────────────────────────────────────────────────────────
      git_metrics.disabled = true;
      time.disabled = true;
      docker_context.disabled = true;
      kubernetes.disabled = true;
      hostname.disabled = true;
      aws.disabled = true;
      gcloud.disabled = true;
      battery.disabled = true;
      username.disabled = true;
      cmd_duration.disabled = true;

      # ─────────────────────────────────────────────────────────────
      # Catppuccin Mocha palette
      # ─────────────────────────────────────────────────────────────
      palette = "catppuccin_mocha";
      palettes.catppuccin_mocha = {
        rosewater = "#f5e0dc";
        flamingo = "#f2cdcd";
        pink = "#f5c2e7";
        mauve = "#cba6f7";
        red = "#f38ba8";
        maroon = "#eba0ac";
        peach = "#fab387";
        yellow = "#f9e2af";
        green = "#a6e3a1";
        teal = "#94e2d5";
        sky = "#89dceb";
        sapphire = "#74c7ec";
        blue = "#89b4fa";
        lavender = "#b4befe";
        text = "#cdd6f4";
        subtext1 = "#bac2de";
        subtext0 = "#a6adc8";
        overlay2 = "#9399b2";
        overlay1 = "#7f849c";
        overlay0 = "#6c7086";
        surface2 = "#585b70";
        surface1 = "#45475a";
        surface0 = "#313244";
        base = "#1e1e2e";
        mantle = "#181825";
        crust = "#11111b";
      };
    };
  };
}
