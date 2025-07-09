# Nix Darwin Configuration

> Declarative, reproducible macOS system configuration using [nix-darwin](https://github.com/nix-darwin/nix-darwin) and [home-manager](https://github.com/nix-community/home-manager).

## Features

- **Declarative System Management** — macOS preferences, packages, and services defined in code
- **Reproducible Environment** — Identical setup across machines with a single command
- **Modern CLI Tooling** — 60+ carefully curated tools replacing legacy Unix utilities
- **Encrypted Secrets** — [sops-nix](https://github.com/Mic92/sops-nix) with age encryption
- **Development Environments** — Per-project shells via direnv + nix flakes
- **Homebrew Integration** — Declarative cask management for macOS-only apps

## Quick Start

```bash
# Install Nix (if not installed)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Clone and apply
git clone <repo-url> ~/.config/nix
cd ~/.config/nix
darwin-rebuild switch --flake .
```

## Project Structure

```
~/.config/nix/
├── flake.nix              # Flake inputs and system definition
├── flake.lock             # Pinned dependencies
│
├── hosts/
│   └── Uross-MacBook-Pro.nix   # System config, Homebrew, macOS defaults
│
├── home/
│   └── kadza.nix          # User packages and home-manager imports
│
├── modules/
│   ├── macos.nix          # macOS system preferences
│   ├── shell.nix          # Zsh, aliases, environment
│   ├── starship.nix       # Prompt configuration
│   ├── git.nix            # Git + delta
│   ├── lazygit.nix        # Git TUI
│   ├── direnv.nix         # Per-directory environments
│   ├── fzf.nix            # Fuzzy finder
│   ├── atuin.nix          # Shell history
│   └── ...                # Additional tool configs
│
├── secrets/
│   └── secrets.yaml       # Encrypted secrets (safe to commit)
│
└── docs/
    └── CAPABILITIES.md    # Detailed feature documentation
```

## Daily Commands

| Command | Description |
|---------|-------------|
| `nrs` | Apply configuration changes |
| `nrb` | Build without switching (test) |
| `nfu` | Update all flake inputs |
| `nvd diff /run/current-system result` | Preview changes before switching |

## What's Included

### System Configuration
- **Keyboard**: Fast key repeat, disabled auto-correct
- **Dock**: Auto-hide, no recents, fast animations
- **Finder**: Show hidden files, column view, path bar
- **Trackpad**: Tap to click, three-finger drag

### CLI Tools (Nix-managed)
| Category | Tools |
|----------|-------|
| **Core** | fd, ripgrep, bat, eza, zoxide, fzf |
| **Git** | delta, lazygit, gh |
| **Data** | jq, yq, miller, glow |
| **System** | bottom, procs, dust, duf |
| **Cloud** | awscli2, kubectl, k9s, helm |
| **Languages** | Node 22, Python 3, Elixir 1.18, Rust, Go |

### macOS Apps (Homebrew casks)
ghostty, headlamp, ngrok, the-unarchiver

## Development Workflows

### Per-Project Environments

```bash
# In any project directory
echo "use flake" > .envrc
direnv allow

# Create flake.nix with project-specific tools
nix flake init
```

### Version Switching (mise)

```bash
mise use node@20      # Project-specific
mise use -g java@17   # Global default
```

## Documentation

- [Capabilities Guide](docs/CAPABILITIES.md) — Detailed feature walkthrough
- [nix-darwin Manual](https://nix-darwin.github.io/nix-darwin/manual/)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.xhtml)
- [Nixpkgs Search](https://search.nixos.org/packages)

## Maintenance

```bash
# Update dependencies
nix flake update

# Garbage collection
nix-collect-garbage --delete-older-than 7d

# Rollback
darwin-rebuild switch --rollback
```

## License

MIT
