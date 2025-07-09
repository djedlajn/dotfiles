# Capabilities Guide

This document provides a detailed walkthrough of the tools, workflows, and features available in this nix-darwin configuration.

## Table of Contents

- [Shell Environment](#shell-environment)
- [File Navigation](#file-navigation)
- [Search & Find](#search--find)
- [Git Workflow](#git-workflow)
- [Development Environments](#development-environments)
- [System Monitoring](#system-monitoring)
- [Cloud & Kubernetes](#cloud--kubernetes)
- [Secrets Management](#secrets-management)
- [macOS Integration](#macos-integration)

---

## Shell Environment

### Zsh with Modern Defaults

The shell is configured with oh-my-zsh and includes:

- **Auto-suggestions** — Type and see suggestions from history
- **Syntax highlighting** — Commands are colored as you type
- **Smart history** — Deduplicated, shared across sessions

### Starship Prompt

Minimal two-line prompt showing:
```
~/.config/nix main !+                              2s
λ
```

- Directory path (blue)
- Git branch (purple)
- Git status (yellow): `!` modified, `+` staged, `↑↓` ahead/behind
- Command duration (if > 2s)
- Lambda prompt (green = success, red = error)

### Atuin (Shell History)

Replacement for standard shell history with fuzzy search:

```bash
# Search history
Ctrl+R          # Open atuin search
↑/↓             # Navigate results
Enter           # Execute selected command
```

### Key Bindings

| Binding | Action |
|---------|--------|
| `Ctrl+A` | Beginning of line |
| `Ctrl+E` | End of line |
| `Ctrl+W` | Delete word backward |
| `Ctrl+R` | Search history (atuin) |
| `Ctrl+X Ctrl+E` | Edit command in $EDITOR |
| `Ctrl+Right` | Forward word |
| `Ctrl+Left` | Backward word |

---

## File Navigation

### Zoxide (Smart cd)

Learns your habits and jumps to directories:

```bash
z projects      # Jump to most frecent match for "projects"
z nix           # Jump to ~/.config/nix (if frequently used)
zi              # Interactive selection with fzf
```

### Yazi (File Manager)

Terminal file manager with vim bindings:

```bash
y               # Open yazi (alias)
```

| Key | Action |
|-----|--------|
| `h/j/k/l` | Navigate |
| `Enter` | Open file/directory |
| `q` | Quit |
| `Space` | Select |
| `d` | Delete |
| `r` | Rename |
| `y` | Copy |
| `p` | Paste |
| `/` | Search |

### Eza (Modern ls)

Replaces `ls` with icons and git integration:

```bash
ls              # eza (alias)
ll              # Long format with details
la              # Include hidden files
tree            # Tree view with icons
```

---

## Search & Find

### Ripgrep (rg)

Fast content search:

```bash
rg "pattern"              # Search current directory
rg "pattern" -t rust      # Only Rust files
rg "pattern" -g "*.tsx"   # Only .tsx files
rg "TODO" --hidden        # Include hidden files
rg -i "error"             # Case insensitive
```

### fd (Modern find)

Fast file finding:

```bash
fd "query"                # Find files matching "query"
fd -e rs                  # Find all .rs files
fd -H                     # Include hidden files
fd -t d                   # Only directories
fd "test" -x rm           # Find and delete (careful!)
```

### fzf (Fuzzy Finder)

Interactive filtering for any list:

```bash
Ctrl+T          # Fuzzy find files
Ctrl+R          # Search history
Alt+C           # cd into directory
**<Tab>         # Trigger completion (e.g., vim **<Tab>)
```

Example workflows:
```bash
# Open file in vim
vim $(fd -t f | fzf)

# Kill process interactively
kill -9 $(ps aux | fzf | awk '{print $2}')

# Checkout git branch
git checkout $(git branch | fzf)
```

---

## Git Workflow

### Lazygit (Git TUI)

Full-featured git interface:

```bash
lg              # Open lazygit (with directory change on exit)
```

| Key | Action |
|-----|--------|
| `j/k` | Navigate |
| `Space` | Stage/unstage |
| `c` | Commit |
| `p` | Push |
| `P` | Pull |
| `b` | Branches |
| `?` | Help |
| `Ctrl+O` | Open in browser |

### Delta (Diff Viewer)

Beautiful diffs with syntax highlighting:

```bash
git diff        # Uses delta automatically
git show        # Uses delta automatically
git log -p      # Uses delta automatically
```

### Git Aliases

```bash
g               # git
gs              # git status
ga              # git add
gaa             # git add --all
gc              # git commit
gcm "msg"       # git commit -m "msg"
gp              # git push
gpf             # git push --force-with-lease
gl              # git pull
gd              # git diff
gds             # git diff --staged
gco             # git checkout
gcb name        # git checkout -b name
glog            # git log --oneline --graph
```

### GitHub CLI (gh)

```bash
gh pr create    # Create pull request
gh pr view      # View current PR
gh pr checkout  # Checkout PR locally
gh issue list   # List issues
gh repo view -w # Open repo in browser
```

---

## Development Environments

### Direnv + Nix Flakes

Automatic per-project environments:

**Setup:**
```bash
cd ~/projects/my-app
echo "use flake" > .envrc
direnv allow
```

**Example flake.nix:**
```nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { nixpkgs, ... }: let
    pkgs = nixpkgs.legacyPackages.aarch64-darwin;
  in {
    devShells.aarch64-darwin.default = pkgs.mkShell {
      packages = with pkgs; [
        nodejs_22
        postgresql_16
      ];

      shellHook = ''
        echo "Dev environment loaded"
      '';
    };
  };
}
```

Now `cd ~/projects/my-app` automatically loads Node.js and PostgreSQL.

### Mise (Version Manager)

Polyglot version management:

```bash
# Install versions
mise install node@20
mise install java@11
mise install python@3.12

# Use globally
mise use -g node@22

# Use in project (creates .mise.toml)
mise use node@20

# List installed
mise ls

# Show current
mise current
```

### Available Runtimes

| Language | Default | Switch with mise |
|----------|---------|------------------|
| Node.js | 22 LTS | `mise use node@20` |
| Java | Zulu 17 | `mise use java@11` |
| Python | 3.x | `mise use python@3.12` |
| Elixir | 1.18 | via nix |
| Rust | stable | via nix (rust-overlay) |
| Go | latest | via nix |

---

## System Monitoring

### Bottom (btm)

System monitor replacing top/htop:

```bash
top             # Opens bottom (alias)
btm             # Direct command
```

| Key | Action |
|-----|--------|
| `q` | Quit |
| `?` | Help |
| `e` | Expand selected widget |
| `/` | Search processes |
| `dd` | Kill process |
| `Tab` | Cycle widgets |

### Other Monitoring Tools

```bash
procs           # Modern ps - process viewer
dust            # Modern du - disk usage by directory
duf             # Modern df - disk free space
bandwhich       # Network usage by process
```

---

## Cloud & Kubernetes

### AWS CLI

```bash
aws configure               # Setup credentials
aws s3 ls                   # List S3 buckets
aws ec2 describe-instances  # List EC2 instances
```

### Kubernetes (kubectl + k9s)

```bash
kubectl get pods            # List pods
kubectl logs -f <pod>       # Stream logs
k9s                         # Open K8s TUI
```

**K9s shortcuts:**

| Key | Action |
|-----|--------|
| `:` | Command mode |
| `/` | Filter |
| `d` | Describe |
| `l` | Logs |
| `s` | Shell into pod |
| `Ctrl+D` | Delete |

### Helm

```bash
helm repo add stable https://charts.helm.sh/stable
helm search repo nginx
helm install my-release stable/nginx
helm list
```

### Additional Tools

```bash
stern           # Multi-pod log tailing
kubectx         # Switch k8s contexts
kubens          # Switch namespaces
```

---

## Secrets Management

### SOPS with Age Encryption

Secrets are encrypted and safe to commit to git.

**Edit secrets:**
```bash
sops secrets/secrets.yaml
```

**Format:**
```yaml
# Decrypted view
api_key: my-secret-value
database:
  password: db-secret
  host: localhost
```

**Use in Nix:**
```nix
sops.secrets.api_key = {};
# Access at: config.sops.secrets.api_key.path
```

### Age Key Location

```
~/.config/sops/age/keys.txt
```

---

## macOS Integration

### Keyboard Settings

- **Fast key repeat** — KeyRepeat: 2, InitialKeyRepeat: 15
- **Disabled auto-correct** — No automatic capitalization, spelling, etc.
- **Full keyboard access** — Tab through all UI controls

### Dock

- Auto-hide with no delay
- No recent apps
- Fast animations

### Finder

- Show hidden files
- Show file extensions
- Column view by default
- Full path in title bar

### Trackpad

- Tap to click
- Three-finger drag
- Two-finger right click

### Screenshots

Saved to `~/Pictures/Screenshots` as PNG without shadows.

---

## Useful Aliases

### Modern Replacements

| Alias | Replacement | Description |
|-------|-------------|-------------|
| `cat` | bat | Syntax highlighting |
| `grep` | ripgrep | Fast search |
| `find` | fd | Fast find |
| `du` | dust | Disk usage |
| `df` | duf | Disk free |
| `top` | bottom | System monitor |
| `dig` | doggo | DNS lookup |

### Navigation

| Alias | Description |
|-------|-------------|
| `..` | cd .. |
| `...` | cd ../.. |
| `....` | cd ../../.. |
| `y` | yazi file manager |

### Nix

| Alias | Command |
|-------|---------|
| `nrs` | darwin-rebuild switch --flake ~/.config/nix |
| `nrb` | darwin-rebuild build --flake ~/.config/nix |
| `nfu` | nix flake update |
| `nsh` | nix-shell |
| `nsp` | nix search nixpkgs |

### Misc

| Alias | Description |
|-------|-------------|
| `path` | Show PATH entries |
| `reload` | Source ~/.zshrc |
| `myip` | Show public IP |
| `ports` | Show listening ports |
| `weather` | Show weather |

---

## Tips & Tricks

### Quick File Preview

```bash
bat file.rs              # Syntax highlighted
glow README.md           # Rendered markdown
hexyl binary.bin         # Hex view
```

### Data Processing

```bash
# JSON
cat data.json | jq '.items[].name'

# YAML
yq '.services' docker-compose.yml

# CSV
mlr --csv filter '$age > 30' data.csv
```

### Benchmarking

```bash
hyperfine 'fd' 'find .'  # Compare command performance
```

### Code Stats

```bash
tokei                    # Lines of code by language
```

### Terminal Recording

```bash
asciinema rec            # Start recording
asciinema play file.cast # Playback
```
