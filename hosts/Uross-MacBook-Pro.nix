{ pkgs, ... }: {
  imports = [
    ../modules/macos.nix # macOS system defaults
  ];

  # Nix daemon is managed by Determinate Nix; the determinate darwin module
  # (imported in flake.nix) sets nix.enable = false and writes custom
  # settings to /etc/nix/nix.custom.conf, which Determinate includes from
  # /etc/nix/nix.conf.
  # Continuous background garbage collection by Determinate Nixd.
  # Old profile generations still need `ngc` (nh clean) to become collectable.
  determinateNix.determinateNixd.garbageCollector.strategy = "automatic";

  determinateNix.customSettings = {
    # Extra binary caches (faster than Hydra for aarch64-darwin)
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.garnix.io"
      "https://claude-code.cachix.org"
      "https://codex-cli.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
      "codex-cli.cachix.org-1:1Br3H1hHoRYG22n//cGKJOk3cQXgYobUel6O8DgSing="
    ];
  };

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
      extensions = [
        "rust-src"
        "rust-analyzer"
      ];
    })
    pkgs.go
  ];

  # Homebrew - for macOS-only apps not in nixpkgs
  homebrew = {
    enable = true;

    # Activation behavior
    onActivation = {
      autoUpdate = true; # Update brew index on rebuild
      # Uninstall + purge anything not declared below. Was temporarily "none"
      # for nix-darwin#1774; the pinned nix-darwin now passes --force-cleanup.
      cleanup = "zap";
      upgrade = true; # Upgrade packages on rebuild
    };

    # Custom taps
    taps = [
      "anomalyco/tap" # opencode
      "can1357/tap" # omp (oh-my-pi)
    ];

    # GUI apps (casks) - Only macOS-specific apps not available in nixpkgs
    casks = [
      "bitwarden" # Password manager with SSH agent
      # claude-code managed declaratively via programs.claude-code (home-manager)
      "command-x" # Cut and paste files in Finder
      "dockutil" # macOS dock management
      "font-jetbrains-mono-nerd-font" # JetBrainsMono with Nerd Font icons
      "font-liberation" # Liberation fonts
      "ghostty" # Terminal emulator (cask kept for Sparkle auto-updates; nixpkgs now has ghostty-bin)
      "headlamp" # Kubernetes GUI IDE
      "ngrok" # Tunneling service
      "raycast" # Spotlight replacement
      "the-unarchiver" # macOS archive utility
    ];

    # CLI tools not in nixpkgs (if any)
    brews = [
      # Official tap + onActivation.upgrade keeps it ~daily fresh; nixpkgs
      # carries opencode too but trails releases by a few days. Move it to
      # home.packages if that lag stops mattering (drops this tap + brews).
      "anomalyco/tap/opencode" # AI coding agent
      # Prebuilt binary from the official tap. The upstream nix flake exists
      # but builds ~1500 uncached derivations from source; brew + upgrade
      # keeps pace with its near-daily releases instead. Not in nixpkgs.
      "can1357/tap/omp" # oh-my-pi AI coding agent
    ];

    # Mac App Store apps (requires `mas` CLI)
    masApps = {
      # "App Name" = app-id;
    };
  };

  # User definition. knownUsers makes nix-darwin manage this account record
  # via dscl — without it the `shell` attribute is silently ignored on
  # activation. Do NOT remove the users.users.kadza block while "kadza" is in
  # knownUsers: nix-darwin deletes known users that are no longer declared.
  users.knownUsers = [ "kadza" ];
  users.users.kadza = {
    name = "kadza";
    home = "/Users/kadza";
    uid = 501; # required (and verified) for knownUsers management
    shell = pkgs.zsh; # Set zsh as default shell
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

  system.stateVersion = 6;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
