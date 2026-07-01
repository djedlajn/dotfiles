{ pkgs, ... }: {
  imports = [
    ../modules/macos.nix  # macOS system defaults
  ];

  # Disable nix-darwin's Nix management (required for Determinate Nix)
  nix.enable = false;

  # Basic system shell support (minimal - just to enable as default shell)
  programs.zsh.enable = true;
  environment.shells = [ pkgs.zsh ];

  # System-wide packages (only essentials - git/curl handled by home-manager)
  environment.systemPackages = [
    pkgs.vim
    pkgs.home-manager
    pkgs.zellij
    pkgs.slides
    pkgs.pulumi
    (pkgs.rust-bin.stable.latest.default.override {
      extensions = [ "rust-src" "rust-analyzer" ];
    })
    pkgs.go
  ];

  # Homebrew - for macOS-only apps not in nixpkgs
  homebrew = {
    enable = true;

    # Activation behavior
    onActivation = {
      autoUpdate = true;       # Update brew index on rebuild
      # cleanup = "zap";       # Disabled: nix-darwin#1774 — brew bundle now
      #                          rejects `--cleanup --zap` without --force-cleanup.
      #                          Re-enable once upstream patches the activation script.
      cleanup = "none";
      upgrade = true;          # Upgrade packages on rebuild
    };

    # Custom taps
    taps = [
      "anomalyco/tap"         # opencode
      "nikitabobko/tap"       # AeroSpace
    ];

    # GUI apps (casks) - Only macOS-specific apps not available in nixpkgs
    casks = [
      "nikitabobko/tap/aerospace"  # Tiling window manager
      "bitwarden"             # Password manager with SSH agent
      # claude-code managed via home-manager activation script
      "command-x"             # Cut and paste files in Finder
      "dockutil"              # macOS dock management
      "font-jetbrains-mono-nerd-font"  # JetBrainsMono with Nerd Font icons
      "font-liberation"       # Liberation fonts
      "ghostty"               # Terminal emulator (not in nixpkgs for macOS)
      "headlamp"              # Kubernetes GUI IDE
      "ngrok"                 # Tunneling service
      "raycast"               # Spotlight replacement
      "session-manager-plugin" # AWS SSM (not in nixpkgs)
      "the-unarchiver"        # macOS archive utility
    ];

    # CLI tools not in nixpkgs (if any)
    brews = [
      "anomalyco/tap/opencode"  # AI coding agent (nix pkg outdated)
    ];

    # Mac App Store apps (requires `mas` CLI)
    masApps = {
      # "App Name" = app-id;
    };
  };

  # User definition
  users.users.kadza = {
    name = "kadza";
    home = "/Users/kadza";
    shell = pkgs.zsh;  # Set zsh as default shell
  };

  # Primary user for user-specific system options (homebrew, etc.)
  system.primaryUser = "kadza";

  # Touch ID for sudo (e.g. in Ghostty). Writes /etc/pam.d/sudo_local,
  # which macOS includes from /etc/pam.d/sudo and preserves across OS updates.
  security.pam.services.sudo_local.touchIdAuth = true;

  # pam_reattach re-attaches sudo to the GUI (Aqua) bootstrap session so the
  # Touch ID prompt appears even when sudo runs inside a terminal multiplexer
  # (zellij/tmux). Without it, sudo inside zellij silently falls back to a
  # password prompt. nix-darwin orders pam_reattach before pam_tid.
  security.pam.services.sudo_local.reattach = true;

  # Declaratively manage nix.custom.conf (nix.settings disabled by nix.enable = false)
  # Determinate Nix includes this via !include in /etc/nix/nix.conf
  environment.etc."nix/nix.custom.conf".text = ''
    # Extra binary caches (faster than Hydra for aarch64-darwin)
    extra-substituters = https://nix-community.cachix.org https://cache.garnix.io
    extra-trusted-public-keys = nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=
  '';
  system.configurationRevision = null; # Set by flake.nix
  system.stateVersion = 6;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
