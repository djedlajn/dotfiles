{ pkgs, ... }:
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
    ../modules/bat.nix
    ../modules/bottom.nix
    ../modules/eza.nix
    ../modules/ripgrep.nix
    ../modules/zoxide.nix
    ../modules/yazi.nix
    ../modules/direnv.nix

    # Git
    ../modules/git.nix
    ../modules/lazygit.nix

    # Security & SSH
    ../modules/bitwarden.nix
    ../modules/sops.nix
    ../modules/ssh.nix

    # macOS apps
    ../modules/aerospace.nix
    ../modules/raycast.nix
  ];

  home.packages = with pkgs; [
    # ─────────────────────────────────────────────────────────────
    # Core CLI (modern replacements)
    # ─────────────────────────────────────────────────────────────
    fd              # find replacement
    jq              # JSON processor
    yq              # YAML/TOML processor
    sd              # sed replacement
    choose          # cut/awk replacement
    curl            # HTTP client
    wget            # HTTP client
    aria2           # Download manager

    # ─────────────────────────────────────────────────────────────
    # Task runners & automation
    # ─────────────────────────────────────────────────────────────
    just            # Command runner (better Make)
    watchexec       # Watch files, run commands
    navi            # Interactive cheatsheets
    gnumake         # GNU Make

    # ─────────────────────────────────────────────────────────────
    # System monitoring
    # ─────────────────────────────────────────────────────────────
    bottom          # System monitor (btm)
    procs           # Modern ps
    dust            # Modern du
    duf             # Modern df
    bandwhich       # Network monitor by process

    # ─────────────────────────────────────────────────────────────
    # Development tools
    # ─────────────────────────────────────────────────────────────
    pre-commit      # Git hooks
    gh              # GitHub CLI
    difftastic      # Structural diff
    tokei           # Code statistics
    hyperfine       # Benchmarking
    dive            # Docker image explorer
    mkcert          # Local TLS certs
    graphviz        # Graph visualization

    # ─────────────────────────────────────────────────────────────
    # Nix tools
    # ─────────────────────────────────────────────────────────────
    nvd             # Nix version diff
    nix-tree        # Visualize nix dependencies

    # ─────────────────────────────────────────────────────────────
    # Formatters & Linters
    # ─────────────────────────────────────────────────────────────
    stylua          # Lua formatter
    shfmt           # Shell formatter
    shellcheck      # Shell linter
    nixfmt          # Nix formatter

    # ─────────────────────────────────────────────────────────────
    # Cloud & Infrastructure
    # ─────────────────────────────────────────────────────────────
    awscli2         # AWS CLI v2
    aws-nuke        # AWS resource cleanup
    # cloud-nuke   # Multi-cloud cleanup (if needed)
    packer          # Image builder

    # Kubernetes
    kubectl         # K8s CLI
    kubernetes-helm # Helm
    k9s             # K8s TUI
    stern           # Multi-pod log tailing
    kubectx         # Context switching

    # ─────────────────────────────────────────────────────────────
    # Languages & Runtimes
    # ─────────────────────────────────────────────────────────────
    # Java (single default version - use mise for switching)
    # Multiple JDK versions conflict in home.packages
    # Use: mise use java@17 / mise use java@11 / mise use java@8
    zulu17          # Default Java (LTS)
    maven           # Java build tool

    # JavaScript/Node
    nodejs_22       # Node.js LTS (includes corepack)
    bun             # Fast JS runtime

    # Python
    uv              # Fast Python package manager
    python3

    # Elixir/Erlang
    beam.packages.erlang_27.elixir_1_18
    beam.packages.erlang_27.erlang
    elixir-ls

    # Go (already in system packages)
    # Rust (already in system packages via rust-overlay)

    tree-sitter     # Parser generator

    # ─────────────────────────────────────────────────────────────
    # HTTP & Network
    # ─────────────────────────────────────────────────────────────
    xh              # Modern curl (httpie-like)
    doggo           # DNS client
    dnsmasq         # DNS/DHCP server

    # ─────────────────────────────────────────────────────────────
    # Text & Data processing
    # ─────────────────────────────────────────────────────────────
    glow            # Markdown renderer
    hexyl           # Hex viewer
    miller          # CSV/JSON/etc processor

    # ─────────────────────────────────────────────────────────────
    # Security & Cryptography
    # ─────────────────────────────────────────────────────────────
    bitwarden-cli   # Password manager CLI (desktop app via homebrew for SSH agent)
    minisign        # Modern code/release signing (Ed25519, simpler than GPG)

    # ─────────────────────────────────────────────────────────────
    # Documentation
    # ─────────────────────────────────────────────────────────────
    tealdeer        # Fast tldr client

    # ─────────────────────────────────────────────────────────────
    # Misc utilities
    # ─────────────────────────────────────────────────────────────
    vivid           # LS_COLORS generator
    silicon         # Code screenshots
    asciinema       # Terminal recording
    fastfetch       # System info
    cmatrix         # Matrix screensaver
    rclone          # Cloud sync
    mise            # Version manager (polyglot)

  ];

  home.stateVersion = "25.05";
  # Note: .gitconfig-greenlight is managed by sops.templates in modules/sops.nix
}
