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
    pkgs.rust-bin.stable.latest.default
    pkgs.go
  ];

  # Homebrew - for macOS-only apps not in nixpkgs
  homebrew = {
    enable = true;

    # Activation behavior
    onActivation = {
      autoUpdate = true;       # Update brew index on rebuild
      cleanup = "zap";         # Remove unlisted packages & casks
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
      "claude-code"           # Claude AI CLI
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

  # nix.settings is managed by Determinate Nix (nix.enable = false above)
  system.configurationRevision = null; # Set by flake.nix
  system.stateVersion = 6;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
