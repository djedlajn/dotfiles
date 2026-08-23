{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    # Shell & Prompt
    ../modules/shell.nix
    ../modules/starship.nix

    # Terminal & Tools
    ../modules/ghostty.nix
    ../modules/fzf.nix
    ../modules/atuin.nix
    ../modules/zellij.nix
    ../modules/tmux.nix
    ../modules/bat.nix
    ../modules/bottom.nix
    ../modules/fastfetch.nix
    ../modules/eza.nix
    ../modules/ripgrep.nix
    ../modules/zoxide.nix
    ../modules/yazi.nix
    ../modules/direnv.nix

    # Git
    ../modules/git.nix
    ../modules/lazygit.nix

    # Sync
    ../modules/syncthing.nix

    # Work
    ../modules/xsolis.nix

    # Security & SSH
    ../modules/bitwarden.nix
    ../modules/sops.nix
    ../modules/ssh.nix
  ];

  home.packages = with pkgs; [
    # ─────────────────────────────────────────────────────────────
    # Core CLI (modern replacements)
    # ─────────────────────────────────────────────────────────────
    fd # find replacement
    jq # JSON processor
    yq # YAML/TOML processor
    sd # sed replacement
    choose # cut/awk replacement
    curl # HTTP client
    wget # HTTP client
    aria2 # Download manager

    # ─────────────────────────────────────────────────────────────
    # Task runners & automation
    # ─────────────────────────────────────────────────────────────
    just # Command runner (better Make)
    watchexec # Watch files, run commands
    navi # Interactive cheatsheets
    gnumake # GNU Make

    # ─────────────────────────────────────────────────────────────
    # System monitoring
    # ─────────────────────────────────────────────────────────────
    bottom # System monitor (btm)
    procs # Modern ps
    dust # Modern du
    duf # Modern df
    bandwhich # Network monitor by process

    # ─────────────────────────────────────────────────────────────
    # Development tools
    # ─────────────────────────────────────────────────────────────
    pre-commit # Git hooks
    gh # GitHub CLI
    jujutsu # Modern VCS (jj)
    television # Fuzzy finder TUI (tv)
    difftastic # Structural diff
    tokei # Code statistics
    hyperfine # Benchmarking
    dive # Docker image explorer
    mkcert # Local TLS certs
    graphviz # Graph visualization
    inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default # TUI agent multiplexer

    # ─────────────────────────────────────────────────────────────
    # Nix tools
    # ─────────────────────────────────────────────────────────────
    nvd # Nix version diff
    nix-tree # Visualize nix dependencies
    nh # Nix helper (pretty rebuilds with diffs)

    # ─────────────────────────────────────────────────────────────
    # Formatters & Linters
    # ─────────────────────────────────────────────────────────────
    stylua # Lua formatter
    shfmt # Shell formatter
    shellcheck # Shell linter
    nixfmt # Nix formatter

    # ─────────────────────────────────────────────────────────────
    # Cloud & Infrastructure
    # ─────────────────────────────────────────────────────────────
    awscli2 # AWS CLI v2
    aws-nuke # AWS resource cleanup
    ssm-session-manager-plugin # AWS SSM session plugin (used by aws cli)
    # cloud-nuke   # Multi-cloud cleanup (if needed)
    packer # Image builder

    # Kubernetes
    kubectl # K8s CLI
    kubernetes-helm # Helm
    k9s # K8s TUI
    stern # Multi-pod log tailing
    kubectx # Context switching

    # ─────────────────────────────────────────────────────────────
    # Languages & Runtimes
    # ─────────────────────────────────────────────────────────────
    # Java (single default version - use mise for switching)
    # Multiple JDK versions conflict in home.packages
    # Use: mise use java@17 / mise use java@11 / mise use java@8
    zulu17 # Default Java (LTS)
    maven # Java build tool

    # JavaScript/Node
    nodejs_24 # Node.js (includes corepack)
    # Bun pinned to 1.3.14: nixpkgs (incl. master) still ships 1.3.13 and
    # oh-my-pi needs >= 1.3.14. Bun has no LTS channel; 1.4.0 is a days-old
    # full rewrite, so stay on the last 1.3 release. Swaps in the official
    # prebuilt zip, so nothing compiles and only this package leaves the
    # cache. Drop the override when nixpkgs bun reaches 1.3.14.
    (bun.overrideAttrs (old: rec {
      version = "1.3.14";
      src = fetchurl {
        url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-darwin-aarch64.zip";
        hash = "sha256-2LliIYKK1vl6x6wKt+lYcjQa92MAHogD6CZ2UsJlJiA=";
      };
    }))

    # Python
    uv # Fast Python package manager
    python3

    # Elixir/Erlang
    beam.packages.erlang_27.elixir_1_18
    beam.packages.erlang_27.erlang
    elixir-ls

    # Go (already in system packages)
    # Rust (already in system packages via rust-overlay)

    cocoapods # iOS dependency manager
    tree-sitter # Parser generator

    # ─────────────────────────────────────────────────────────────
    # HTTP & Network
    # ─────────────────────────────────────────────────────────────
    xh # Modern curl (httpie-like)
    doggo # DNS client
    dnsmasq # DNS/DHCP server
    cloudflared # Cloudflare Tunnel client

    # ─────────────────────────────────────────────────────────────
    # Text & Data processing
    # ─────────────────────────────────────────────────────────────
    glow # Markdown renderer
    hexyl # Hex viewer
    miller # CSV/JSON/etc processor

    # ─────────────────────────────────────────────────────────────
    # Security & Cryptography
    # ─────────────────────────────────────────────────────────────
    bitwarden-cli # Password manager CLI (desktop app via homebrew for SSH agent)
    minisign # Modern code/release signing (Ed25519, simpler than GPG)

    # ─────────────────────────────────────────────────────────────
    # Documentation
    # ─────────────────────────────────────────────────────────────
    tealdeer # Fast tldr client

    # ─────────────────────────────────────────────────────────────
    # Misc utilities
    # ─────────────────────────────────────────────────────────────
    ouch # Universal compress/decompress
    trippy # Network diagnostics TUI
    vivid # LS_COLORS generator
    silicon # Code screenshots
    asciinema # Terminal recording
    cmatrix # Matrix screensaver
    rclone # Cloud sync
    mise # Version manager (polyglot)

  ];

  # Claude Code - declarative, from sadjow/claude-code-nix (updated hourly
  # from Anthropic's releases, cached at claude-code.cachix.org; the wrapper
  # sets DISABLE_AUTOUPDATER=1 since the store path is read-only). Update
  # with `nfu` like everything else. Runtime state (~/.claude.json, ~/.claude)
  # stays unmanaged on purpose - Claude rewrites those files itself.
  programs.claude-code = {
    enable = true;
    package = inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
  };

  # Codex CLI - declarative, from sadjow/codex-cli-nix (same author and setup
  # as claude-code above: updated hourly from OpenAI's releases, cached at
  # codex-cli.cachix.org, native Rust binary). Update with `nfu` like
  # everything else. Runtime state (~/.codex: config.toml, auth.json, ...)
  # stays unmanaged on purpose - Codex rewrites those files itself.
  programs.codex = {
    enable = true;
    package = inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };

  # macOS saves screenshots here (system.defaults.screencapture.location in
  # modules/macos.nix) but silently drops them if the folder doesn't exist.
  home.activation.screenshotsDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "$HOME/Pictures/Screenshots"
  '';

  home.stateVersion = "25.05";
}
