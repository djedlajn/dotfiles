# dotfiles

Declarative macOS system configuration powered by [Nix](https://nixos.org), [nix-darwin](https://github.com/nix-darwin/nix-darwin), and [home-manager](https://github.com/nix-community/home-manager).

```
~/.config/nix
├── flake.nix           # Flake definition & inputs
├── hosts/              # Per-machine system config
├── home/               # User packages & home-manager imports
├── modules/            # Modular tool configurations
├── secrets/            # Encrypted secrets (sops)
└── docs/               # Extended documentation
```

## Features

- **Reproducible** — Single command rebuilds identical environment anywhere
- **Modular** — Each tool configured in its own module
- **Secure** — Secrets encrypted with [sops-nix](https://github.com/Mic92/sops-nix) + age
- **Modern CLI** — 70+ tools replacing legacy Unix utilities
- **macOS native** — System preferences, Dock, Finder, keyboard all in code

## Quick Start

### Prerequisites

- macOS (Apple Silicon)
- [Determinate Nix](https://determinate.systems/nix-installer)

### Install

```bash
# Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Clone
git clone https://github.com/djedlajn/dotfiles ~/.config/nix
cd ~/.config/nix

# Apply (first run takes ~10 min)
darwin-rebuild switch --flake .
```

## What's Included

### Shell & Terminal

| Tool | Description |
|------|-------------|
| [zsh](https://www.zsh.org/) | Shell with oh-my-zsh, autosuggestions, syntax highlighting |
| [starship](https://starship.rs/) | Minimal prompt with Catppuccin Mocha theme |
| [atuin](https://atuin.sh/) | Shell history with fuzzy search |
| [ghostty](https://ghostty.org/) | GPU-accelerated terminal |
| [zellij](https://zellij.dev/) | Terminal multiplexer |

### File & Navigation

| Tool | Replaces | Description |
|------|----------|-------------|
| [eza](https://eza.rocks/) | `ls` | Modern ls with icons & git |
| [bat](https://github.com/sharkdp/bat) | `cat` | Syntax highlighting |
| [fd](https://github.com/sharkdp/fd) | `find` | Fast file finder |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | `grep` | Fast content search |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | `cd` | Smart directory jumping |
| [yazi](https://yazi-rs.github.io/) | — | Terminal file manager |
| [fzf](https://github.com/junegunn/fzf) | — | Fuzzy finder |

### Git

| Tool | Description |
|------|-------------|
| [lazygit](https://github.com/jesseduffield/lazygit) | Git TUI |
| [delta](https://github.com/dandavison/delta) | Syntax-highlighted diffs |
| [gh](https://cli.github.com/) | GitHub CLI |
| [difftastic](https://difftastic.wilfred.me.uk/) | Structural diff |

### System Monitoring

| Tool | Replaces | Description |
|------|----------|-------------|
| [bottom](https://clementtsang.github.io/bottom/) | `top` | System monitor |
| [procs](https://github.com/dalance/procs) | `ps` | Process viewer |
| [dust](https://github.com/bootandy/dust) | `du` | Disk usage |
| [duf](https://github.com/muesli/duf) | `df` | Disk free |
| [bandwhich](https://github.com/imsnif/bandwhich) | — | Network by process |

### Languages & Runtimes

| Language | Version | Notes |
|----------|---------|-------|
| Node.js | 22 LTS | via nix, switchable with mise |
| Bun | latest | Fast JS runtime |
| Python | 3.x | with uv package manager |
| Java | Zulu 17 | via nix, switchable with mise |
| Elixir | 1.18 | with Erlang/OTP 27 |
| Rust | stable | via rust-overlay |
| Go | latest | via nix |

### Cloud & Infrastructure

```
awscli2 · kubectl · helm · k9s · stern · kubectx · packer
```

### macOS Apps (via Homebrew)

```
ghostty · aerospace · bitwarden · raycast · headlamp · ngrok
```

## Usage

### Daily Commands

| Alias | Command | Description |
|-------|---------|-------------|
| `nrs` | `darwin-rebuild switch --flake ~/.config/nix` | Apply changes |
| `nrb` | `darwin-rebuild build --flake ~/.config/nix` | Build without switching |
| `nfu` | `nix flake update` | Update all inputs |

### Development Environments

Per-project shells with direnv:

```bash
cd ~/projects/my-app
echo "use flake" > .envrc
direnv allow
```

Example `flake.nix`:

```nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = { nixpkgs, ... }: {
    devShells.aarch64-darwin.default = nixpkgs.legacyPackages.aarch64-darwin.mkShell {
      packages = with nixpkgs.legacyPackages.aarch64-darwin; [ nodejs_22 postgresql_16 ];
    };
  };
}
```

### Secrets

Encrypted with sops + age:

```bash
sops secrets/secrets.yaml  # Edit secrets
```

## Module Structure

Each tool is configured in its own module under `modules/`:

```
modules/
├── shell.nix       # Zsh, aliases, environment
├── starship.nix    # Prompt with Catppuccin palette
├── git.nix         # Git + delta
├── lazygit.nix     # Git TUI
├── atuin.nix       # Shell history
├── fzf.nix         # Fuzzy finder
├── yazi.nix        # File manager
├── bat.nix         # Cat replacement
├── bottom.nix      # System monitor
├── ghostty.nix     # Terminal config
├── zellij.nix      # Multiplexer
├── aerospace.nix   # Tiling window manager
├── macos.nix       # System preferences
├── sops.nix        # Secrets
└── ...
```

## macOS Preferences

Configured via `modules/macos.nix`:

- **Keyboard**: Fast repeat (2/15), no auto-correct
- **Dock**: Auto-hide, no recents, fast animations
- **Finder**: Hidden files, extensions, column view, path bar
- **Trackpad**: Tap to click, three-finger drag
- **Screenshots**: `~/Pictures/Screenshots`, PNG, no shadows

## Maintenance

```bash
# Update flake inputs
nix flake update

# Garbage collection
nix-collect-garbage --delete-older-than 7d

# Rollback
darwin-rebuild switch --rollback

# Preview changes before switching
nvd diff /run/current-system result
```

## Documentation

- [Capabilities Guide](docs/CAPABILITIES.md) — Detailed feature documentation
- [nix-darwin Manual](https://nix-darwin.github.io/nix-darwin/manual/)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.xhtml)
- [Nixpkgs Search](https://search.nixos.org/packages)

## License

MIT
