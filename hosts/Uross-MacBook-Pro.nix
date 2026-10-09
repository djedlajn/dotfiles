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
      "https://claude-code.cachix.org"
      "https://codex-cli.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
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

    # Rebuilds only converge to the declared set; they never fetch the brew
    # index or upgrade anything, so `nrs` stays fast and repeatable. Upgrade
    # brew items explicitly with `bwu`.
    onActivation = {
      # Uninstall + purge anything not declared below. Was temporarily "none"
      # for nix-darwin#1774; the pinned nix-darwin now passes --force-cleanup.
      cleanup = "zap";
    };
    # Also exports HOMEBREW_NO_AUTO_UPDATE=1 system-wide.
    global.autoUpdate = false;

    # Custom taps
    taps = [
      "can1357/tap" # omp (oh-my-pi)
    ];

    # GUI apps (casks) - Only macOS-specific apps not available in nixpkgs
    casks = [
      "bitwarden" # Password manager with SSH agent
      # claude-code managed declaratively via programs.claude-code (home-manager)
      # Nightly builds that update themselves; config lives in programs.ghostty
      # (modules/ghostty.nix, package = null).
      "ghostty@tip" # Terminal
      "headlamp" # Kubernetes GUI IDE
      "ngrok" # Tunneling service
      "raycast" # Spotlight replacement (configured through its UI; settings sync via Raycast account)
      "the-unarchiver" # macOS archive utility
    ];

    brews = [
      # Prebuilt binary from the official tap. The upstream nix flake exists
      # but builds ~1500 uncached derivations from source; brew + `bwu`
      # keeps pace with its near-daily releases instead. Not in nixpkgs.
      "can1357/tap/omp" # oh-my-pi AI coding agent
    ];

    # Mac App Store apps (nix-darwin supplies `mas` during activation). Already
    # installed; declared so a fresh machine restores them. Upgrades go
    # through the App Store, not activation.
    masApps = {
      Xcode = 497799835;
      TestFlight = 899247664;
      "Okta Verify" = 490179405;
    };
  };

  # Fonts land in /Library/Fonts/Nix Fonts; replaces the two font casks.
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono # Ghostty's JetBrainsMono Nerd Font Mono
    pkgs.liberation_ttf
  ];

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
