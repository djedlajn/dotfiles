# dotfiles

Declarative macOS configuration with [nix-darwin](https://github.com/nix-darwin/nix-darwin) and [home-manager](https://github.com/nix-community/home-manager).

Everything uses the **Catppuccin Mocha** color scheme.

```
~/.config/nix
├── flake.nix           # Flake definition & inputs
├── hosts/              # Per-machine system config
├── home/               # User packages & home-manager imports
├── modules/            # Modular tool configurations
├── secrets/            # Encrypted secrets (sops)
└── docs/               # Extended documentation
```

## Quick Start

```bash
# Install Nix (Determinate Systems installer)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Clone
git clone https://github.com/djedlajn/dotfiles ~/.config/nix
cd ~/.config/nix

# Apply
darwin-rebuild switch --flake .
```

## What's Included

### Terminal

| Tool | Description | Theme |
|------|-------------|-------|
| [Ghostty](https://ghostty.org/) | GPU-accelerated terminal | Catppuccin Mocha |
| [Zellij](https://zellij.dev/) | Terminal multiplexer | Catppuccin Mocha |
| [Starship](https://starship.rs/) | Minimal prompt with language versions | Catppuccin Mocha |

**Ghostty features:**
- Font: JetBrainsMono Nerd Font (14pt)
- Quick terminal: `Cmd+`` (Quake-style dropdown)
- Splits: `Cmd+Shift+Enter` (right), `Cmd+Shift+-` (down)
- Scrollback: 100,000 lines

### Shell

| Tool | Description |
|------|-------------|
| [zsh](https://www.zsh.org/) | Shell with oh-my-zsh |
| [atuin](https://atuin.sh/) | Shell history with fuzzy search |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder with file preview |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart cd (replaces `cd` entirely) |
| [direnv](https://direnv.net/) | Per-project environments with nix-direnv |

**Zsh plugins:** git, docker, brew, macos, colored-man-pages, kubectl

**Key bindings:**
| Key | Action |
|-----|--------|
| `Ctrl+R` | Search history (atuin) |
| `Ctrl+T` | Fuzzy find files (fzf) |
| `Alt+C` | cd into directory (fzf) |
| `Ctrl+X Ctrl+E` | Edit command in `$EDITOR` |

### File Navigation

| Tool | Replaces | Description |
|------|----------|-------------|
| [eza](https://eza.rocks/) | `ls` | Icons, git status, directories first |
| [fd](https://github.com/sharkdp/fd) | `find` | Fast file finder |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | `grep` | Smart-case, hidden files, custom ignores |
| [bat](https://github.com/sharkdp/bat) | `cat` | Syntax highlighting + batdiff, batman, batgrep |
| [yazi](https://yazi-rs.github.io/) | — | File manager with Catppuccin theme |

**Yazi keybindings:** `y` to open, vim-style navigation, `Ctrl+G` for lazygit

### Git

| Tool | Description |
|------|-------------|
| [lazygit](https://github.com/jesseduffield/lazygit) | Git TUI with Catppuccin theme |
| [delta](https://github.com/dandavison/delta) | Side-by-side diffs with syntax highlighting |
| [gh](https://cli.github.com/) | GitHub CLI |

**Git features:**
- SSH commit signing (ed25519)
- Credential helper: `gh auth git-credential`
- Auto-fetch, auto-stash on rebase
- Histogram diff algorithm

**Lazygit custom commands:**
| Key | Action |
|-----|--------|
| `Ctrl+O` | Open PR/repo in browser |
| `Ctrl+B` | Browse commit on GitHub |
| `O` | Create PR (on branches) |
| `F` | Fetch all remotes |

### System Monitoring

| Tool | Replaces | Description |
|------|----------|-------------|
| [bottom](https://clementtsang.github.io/bottom/) | `top` | Process tree, GPU, battery |
| [procs](https://github.com/dalance/procs) | `ps` | Process viewer |
| [dust](https://github.com/bootandy/dust) | `du` | Disk usage |
| [duf](https://github.com/muesli/duf) | `df` | Disk free |
| [bandwhich](https://github.com/imsnif/bandwhich) | — | Network by process |

### Window Management

[AeroSpace](https://github.com/nikitabobko/AeroSpace) — i3-like tiling for macOS

| Key | Action |
|-----|--------|
| `Alt+H/J/K/L` | Focus left/down/up/right |
| `Alt+Shift+H/J/K/L` | Move window |
| `Alt+1-9` | Switch workspace |
| `Alt+Shift+1-9` | Move to workspace |
| `Alt+F` | Fullscreen |
| `Alt+Tab` | Back and forth |

### Languages & Runtimes

| Language | Version | Notes |
|----------|---------|-------|
| Node.js | 22 LTS | + Bun |
| Python | 3.x | with uv package manager |
| Java | Zulu 17 | switchable with mise |
| Elixir | 1.18 | Erlang/OTP 27 |
| Rust | stable | via rust-overlay |
| Go | latest | — |

### Cloud & Infrastructure

```
awscli2 · kubectl · helm · k9s · stern · kubectx · packer
```

### Security

- **SSH keys**: Managed via sops-nix, decrypted to `~/.ssh/`
- **SSH agent**: Bitwarden primary, macOS Keychain fallback
- **Commit signing**: SSH with ed25519
- **Touch ID**: Enabled for sudo

### macOS Apps (Homebrew)

```
ghostty · aerospace · bitwarden · raycast · headlamp · ngrok
```

## Aliases

### Modern Replacements

```bash
cat → bat       grep → rg       find → fd
du → dust       df → duf        top → btm
ps → procs      dig → doggo
```

### Git

```bash
g       # git
gs      # git status
ga      # git add
gaa     # git add --all
gc      # git commit
gcm     # git commit -m
gp      # git push
gpf     # git push --force-with-lease
gl      # git pull
gd      # git diff
gds     # git diff --staged
gco     # git checkout
gcb     # git checkout -b
glog    # git log --oneline --graph
lg      # lazygit (with directory change on exit)
```

### Nix

```bash
nrs     # darwin-rebuild switch --flake ~/.config/nix
nrb     # darwin-rebuild build --flake ~/.config/nix
nfu     # nix flake update
nfc     # nix flake check
nsh     # nix-shell
nsp     # nix search nixpkgs
```

### Navigation

```bash
..      # cd ..
...     # cd ../..
....    # cd ../../..
y       # yazi
zj      # zellij
z <dir> # zoxide jump
```

## macOS Preferences

Configured via `modules/macos.nix`:

- **Keyboard**: Fast repeat (2/15), no auto-correct, no smart quotes
- **Dock**: Auto-hide, no delay, no recents, scale effect
- **Finder**: Hidden files, extensions, column view, path bar, quit via Cmd+Q
- **Trackpad**: Tap to click, two-finger right click
- **Screenshots**: `~/Pictures/Screenshots`, PNG, no shadows
- **Menu bar**: 24-hour clock
- **Security**: Touch ID for sudo

## Direnv Layouts

Custom functions in `~/.config/direnv/direnvrc`:

```bash
use flake           # Load nix flake devShell
layout node         # Add node_modules/.bin to PATH
layout python_venv  # Create/activate Python venv
use mise            # Use mise for version management
```

## Documentation

- [Capabilities Guide](docs/CAPABILITIES.md) — Detailed keybindings and workflows
- [nix-darwin Manual](https://nix-darwin.github.io/nix-darwin/manual/)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.xhtml)

## Maintenance

```bash
nix flake update                              # Update inputs
nix-collect-garbage --delete-older-than 7d    # Cleanup
darwin-rebuild switch --rollback              # Rollback
nvd diff /run/current-system result           # Preview changes
```

## License

MIT
