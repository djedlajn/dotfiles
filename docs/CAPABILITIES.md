# Capabilities Guide

Detailed reference for all tools, keybindings, and configurations.

All tools use the **Catppuccin Mocha** color scheme.

---

## Table of Contents

- [Terminal (Ghostty)](#terminal-ghostty)
- [Shell (Zsh)](#shell-zsh)
- [History (Atuin)](#history-atuin)
- [Fuzzy Finder (fzf)](#fuzzy-finder-fzf)
- [Multiplexer (Zellij)](#multiplexer-zellij)
- [Prompt (Starship)](#prompt-starship)
- [File Manager (Yazi)](#file-manager-yazi)
- [Git (Lazygit + Delta)](#git-lazygit--delta)
- [Window Manager (AeroSpace)](#window-manager-aerospace)
- [Development (Direnv)](#development-direnv)
- [System Monitoring](#system-monitoring)
- [macOS Preferences](#macos-preferences)
- [Secrets (SOPS)](#secrets-sops)
- [SSH Configuration](#ssh-configuration)

---

## Terminal (Ghostty)

GPU-accelerated terminal with Catppuccin Mocha theme.

**Font:** JetBrainsMono Nerd Font Mono, 14pt

| Keybinding | Action |
|------------|--------|
| `Cmd+`` | Toggle quick terminal (Quake-style dropdown) |
| `Cmd+T` | New tab |
| `Cmd+W` | Close surface |
| `Cmd+Shift+Enter` | Split right |
| `Cmd+Shift+-` | Split down |
| `Cmd+Opt+Arrow` | Navigate splits |
| `Cmd+Shift+F` | Toggle fullscreen |
| `Cmd++/-/0` | Zoom in/out/reset |

**Settings:**
- Window padding: 12x10
- Option as Alt: enabled
- Copy on select: clipboard
- Scrollback: 100,000 lines

---

## Shell (Zsh)

Configured with oh-my-zsh and modern plugins.

**Plugins:** git, docker, brew, macos, colored-man-pages, command-not-found, kubectl

**Environment:**
```bash
EDITOR=vim
MANPAGER="sh -c 'col -bx | bat -l man -p'"
LS_COLORS="$(vivid generate snazzy)"
```

### Key Bindings

| Binding | Action |
|---------|--------|
| `Ctrl+A` | Beginning of line |
| `Ctrl+E` | End of line |
| `Ctrl+W` | Delete word backward |
| `Ctrl+X Ctrl+E` | Edit command in $EDITOR |
| `Ctrl+Right` | Forward word |
| `Ctrl+Left` | Backward word |
| `Up/Down` | History search (prefix-based) |

### Aliases

**Modern replacements:**
```bash
cat=bat  grep=rg  find=fd  du=dust  df=duf
ps=procs  top=btm  htop=btm  dig=doggo
```

**Git:**
```bash
g=git  gs="git status"  ga="git add"  gaa="git add --all"
gc="git commit"  gcm="git commit -m"  gca="git commit --amend"
gp="git push"  gpf="git push --force-with-lease"  gl="git pull"
gd="git diff"  gds="git diff --staged"
gco="git checkout"  gcb="git checkout -b"  gb="git branch"
glog="git log --oneline --graph --decorate"
```

**Nix:**
```bash
nrs="darwin-rebuild switch --flake ~/.config/nix"
nrb="darwin-rebuild build --flake ~/.config/nix"
nfu="nix flake update --flake ~/.config/nix"
nfc="nix flake check ~/.config/nix"
nsh="nix-shell"  nsp="nix search nixpkgs"
```

**Navigation:**
```bash
..="cd .."  ...="cd ../.."  ....="cd ../../.."
y=yazi  zj=zellij  tree="eza --tree --icons"
```

**Utilities:**
```bash
mkdir="mkdir -pv"  cp="cp -iv"  mv="mv -iv"  rm="rm -v"
path="echo $PATH | tr ':' '\n'"
reload="source ~/.zshrc"
weather="curl wttr.in"
myip="curl ifconfig.me"
ports="lsof -iTCP -sTCP:LISTEN -n -P"
```

---

## History (Atuin)

Shell history with fuzzy search and custom Catppuccin theme.

**Style:** Compact, 25 lines, with preview

| Binding | Action |
|---------|--------|
| `Ctrl+R` | Open atuin search |
| `Up/Down` | Navigate results |
| `Enter` | Execute command |

**Settings:**
- Search mode: fuzzy
- Filter mode: global (session for up-arrow)
- Secrets filtered: passwords, tokens, AWS keys
- Sync: disabled

**Tracked subcommands:** cargo, docker, git, go, kubectl, nix, npm, pnpm, yarn, mix, iex

---

## Fuzzy Finder (fzf)

Interactive filtering with Catppuccin colors and bat preview.

| Binding | Action |
|---------|--------|
| `Ctrl+T` | Fuzzy find files (paste path) |
| `Ctrl+R` | Search history |
| `Alt+C` | cd into directory |
| `**<Tab>` | Trigger completion |
| `Ctrl+D/U` | Preview scroll down/up |

**Preview:**
- Files: `bat --style=numbers --color=always`
- Directories: `eza --tree --level=2 --icons`

**Ignored:** `.git/`

---

## Multiplexer (Zellij)

Terminal multiplexer with Catppuccin Mocha theme.

| Binding | Action |
|---------|--------|
| `Ctrl+G` | Enter/exit locked mode |
| `Ctrl+P` | Pane mode |
| `Alt+N` | New pane |
| `Alt+H/Left` | Move focus/tab left |

**Pane mode (after Ctrl+P):**
| Key | Action |
|-----|--------|
| `H/J/K/L` | Move focus |
| `P` | Switch focus |

---

## Prompt (Starship)

Minimal two-line prompt with language versions on the right.

```
󱍢  ~/.config/nix  main !+                          22
```

**Format:**
- Left: `$nix_shell$character$directory$git_branch$git_status`
- Right: `$nodejs$bun$java$kotlin$rust$golang$python$package`

**Symbols:**
| Symbol | Meaning |
|--------|---------|
| `󱍢` | Prompt (green=success, red=error, yellow=vim mode) |
| `` | Directory |
| `` | Git branch |
| `!` | Modified files |
| `+` | Staged files |
| `⇡/⇣` | Ahead/behind |
| `?` | Untracked |

**Language icons:** ` ` Node,  ` ` Bun, ` ` Java, ` ` Rust, ` ` Go, ` ` Python

**Disabled:** time, docker_context, kubernetes, hostname, aws, gcloud, battery, username, cmd_duration

---

## File Manager (Yazi)

Terminal file manager with Catppuccin theme and vim keybindings.

| Key | Action |
|-----|--------|
| `h/j/k/l` | Navigate (parent/down/up/enter) |
| `J/K` | Move 5 lines |
| `gg/G` | Top/bottom |
| `Enter` | Open file |
| `q` | Quit |
| `Space` | Toggle selection |
| `v/V` | Visual mode |
| `Ctrl+A` | Select all |

**Operations:**
| Key | Action |
|-----|--------|
| `y` | Yank (copy) |
| `x` | Cut |
| `p/P` | Paste / paste (overwrite) |
| `d/D` | Delete / delete permanently |
| `a` | Create file/directory |
| `r` | Rename |

**Search/Filter:**
| Key | Action |
|-----|--------|
| `/` | Find |
| `?` | Find previous |
| `n/N` | Next/previous match |
| `f` | Filter |

**Sorting (`,` prefix):**
| Key | Action |
|-----|--------|
| `,m/M` | By modified (asc/desc) |
| `,n/N` | By name (asc/desc) |
| `,s/S` | By size (asc/desc) |

**Tabs:**
| Key | Action |
|-----|--------|
| `t` | New tab |
| `1-3` | Switch tab |
| `[/]` | Previous/next tab |

**Goto:**
| Key | Action |
|-----|--------|
| `gh` | Home |
| `gc` | ~/.config |
| `gd` | ~/Downloads |

**Integration:**
| Key | Action |
|-----|--------|
| `Ctrl+G` | Open lazygit |
| `:` | Shell command |
| `.` | Toggle hidden |

---

## Git (Lazygit + Delta)

### Lazygit

Git TUI with Catppuccin theme and Nerd Font icons.

| Key | Action |
|-----|--------|
| `j/k` | Navigate |
| `Space` | Stage/unstage |
| `c` | Commit |
| `p/P` | Push/pull |
| `b` | Branches |
| `?` | Help |

**Custom commands:**
| Key | Context | Action |
|-----|---------|--------|
| `Ctrl+O` | Global | Open PR/repo in browser |
| `Ctrl+B` | Commits | Browse commit on GitHub |
| `O` | Local branches | Create PR on GitHub |
| `F` | Global | Fetch all remotes |

**Pager:** Delta with line numbers and clickable file links

### Delta

Side-by-side diffs with Catppuccin syntax highlighting.

**Features:**
- Side-by-side view
- Line numbers
- Navigate between files with `n/N`
- Syntax theme: catppuccin-mocha

### Git Config

**Signing:** SSH with ed25519 key
**Credential helper:** `gh auth git-credential`

**Behavior:**
- Default branch: main
- Pull: rebase
- Push: auto-setup remote
- Rebase: auto-stash
- Rerere: enabled
- Diff algorithm: histogram

**Global ignores:** `.DS_Store`, `.vscode/`, `.idea/`, `node_modules/`, `.env*`, `dist/`, `build/`

---

## Window Manager (AeroSpace)

i3-like tiling window manager for macOS.

### Focus & Move

| Key | Action |
|-----|--------|
| `Alt+H/J/K/L` | Focus left/down/up/right |
| `Alt+Shift+H/J/K/L` | Move window left/down/up/right |

### Workspaces

| Key | Action |
|-----|--------|
| `Alt+1-9` | Switch to workspace |
| `Alt+Shift+1-9` | Move window to workspace |
| `Alt+Tab` | Workspace back and forth |
| `Alt+Shift+Tab` | Move workspace to next monitor |

### Layout

| Key | Action |
|-----|--------|
| `Alt+/` | Toggle tiles horizontal/vertical |
| `Alt+,` | Toggle accordion |
| `Alt+F` | Fullscreen |
| `Alt+Shift+Space` | Toggle floating/tiling |
| `Alt+-/=` | Resize -50/+50 |

### Service Mode (`Alt+Shift+;`)

| Key | Action |
|-----|--------|
| `Esc` | Reload config, exit |
| `R` | Flatten workspace tree |
| `F` | Toggle floating |
| `Backspace` | Close all but current |

**Floating apps:** System Preferences, Finder dialogs, 1Password, Raycast

---

## Development (Direnv)

Per-project environments with nix-direnv.

**Whitelisted directories:** `~/greenlight`, `~/projects`, `~/code`

### Custom Layouts

```bash
# In .envrc
use flake              # Load nix flake devShell
layout node            # Add node_modules/.bin to PATH
layout python_venv     # Create/activate .venv
use mise               # Use mise for versions
```

### Example .envrc

```bash
use flake
layout node
```

### Example flake.nix

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

---

## System Monitoring

### Bottom (btm)

System monitor with Catppuccin theme.

| Key | Action |
|-----|--------|
| `q` | Quit |
| `?` | Help |
| `e` | Expand widget |
| `/` | Search processes |
| `dd` | Kill process |
| `Tab` | Cycle widgets |

**Features:** Process tree, GPU monitoring, battery, cache memory

### Other Tools

```bash
procs           # Process viewer (colored, tree)
dust            # Disk usage by directory
duf             # Disk free (with graph)
bandwhich       # Network usage by process
```

---

## macOS Preferences

### Keyboard

- Key repeat: 2 (fast)
- Initial repeat: 15 (short delay)
- Press and hold: disabled (key repeat works)
- Full keyboard access: enabled
- Auto-correct/capitalize/dash/period/quote/spelling: all disabled

### Dock

- Auto-hide: enabled
- Auto-hide delay: 0
- Animation: 0.4s
- Size: 38px
- Minimize effect: scale
- Show recents: disabled
- Rearrange spaces: disabled
- Mission Control animation: 0.15s

### Finder

- Show hidden files: yes
- Show extensions: yes
- Path bar: yes
- Status bar: yes
- Default view: column
- Search scope: current folder
- Extension warning: disabled
- Quit via Cmd+Q: enabled
- Full POSIX path in title: yes

### Trackpad

- Tap to click: enabled
- Two-finger right click: enabled
- Three-finger swipe: Spaces & Mission Control

### Screenshots

- Location: `~/Pictures/Screenshots`
- Format: PNG
- Shadows: disabled

### Menu Bar

- Clock: 24-hour format

### Security

- Touch ID for sudo: enabled
- Guest account: disabled

### Other

- Save to disk by default (not iCloud)
- Expand save/print panels by default
- Disable disk image verification
- No .DS_Store on network/USB volumes
- Photos: disable auto-open on device connect

---

## Secrets (SOPS)

Encrypted secrets with age encryption.

**Key file:** `~/.config/sops/age/keys.txt`

**Decrypted secrets:**
- `~/.ssh/id_ed25519` (personal)
- `~/.ssh/green_ed25519` (work)
- `~/.gitconfig-greenlight` (work email)

### Usage

```bash
sops secrets/secrets.yaml   # Edit secrets
```

---

## SSH Configuration

### Agent Priority

1. Bitwarden SSH Agent (`~/.bitwarden-ssh-agent.sock`)
2. Existing SSH_AUTH_SOCK
3. macOS launchd socket

### Features

- Keychain integration: enabled
- Add keys to agent: enabled
- Forward agent: enabled

### Host-specific Keys

- Default: `~/.ssh/id_ed25519`
- `*.greenlight.guru`: `~/.ssh/green_ed25519`

### Commit Signing

SSH signature verification via `~/.ssh/allowed_signers`
