# Capabilities Guide

Detailed walkthrough of tools, workflows, and features in this configuration.

---

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
- [Aliases Reference](#aliases-reference)

---

## Shell Environment

### Zsh

Configured with oh-my-zsh and modern plugins:

| Feature | Description |
|---------|-------------|
| Auto-suggestions | Type and see suggestions from history |
| Syntax highlighting | Commands colored as you type |
| Smart history | Deduplicated, shared across sessions |

### Starship Prompt

Minimal left prompt with language versions on the right:

```
󱍢  ~/.config/nix  main !+                          22
```

| Element | Meaning |
|---------|---------|
| `󱍢` | Prompt (green = success, red = error) |
| `~/.config/nix` | Current directory |
| `main` | Git branch |
| `!` | Modified files |
| `+` | Staged files |
| ` 22` | Node.js version (right side) |

Theme: **Catppuccin Mocha**

### Atuin

Shell history replacement with fuzzy search:

| Binding | Action |
|---------|--------|
| `Ctrl+R` | Open atuin search |
| `↑/↓` | Navigate results |
| `Enter` | Execute command |

### Key Bindings

| Binding | Action |
|---------|--------|
| `Ctrl+A` | Beginning of line |
| `Ctrl+E` | End of line |
| `Ctrl+W` | Delete word backward |
| `Ctrl+R` | Search history (atuin) |
| `Ctrl+X Ctrl+E` | Edit command in `$EDITOR` |
| `Ctrl+Right` | Forward word |
| `Ctrl+Left` | Backward word |

---

## File Navigation

### Zoxide

Smart `cd` that learns your habits:

```bash
z projects      # Jump to most frecent match
z nix           # Jump to ~/.config/nix
zi              # Interactive selection with fzf
```

### Yazi

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

### Eza

Modern `ls` with icons and git integration:

```bash
ls              # eza (alias)
ll              # Long format
la              # Include hidden
tree            # Tree view
```

---

## Search & Find

### Ripgrep

Fast content search:

```bash
rg "pattern"              # Search current directory
rg "pattern" -t rust      # Only Rust files
rg "pattern" -g "*.tsx"   # Only .tsx files
rg "TODO" --hidden        # Include hidden files
rg -i "error"             # Case insensitive
```

### fd

Fast file finding:

```bash
fd "query"                # Find files matching "query"
fd -e rs                  # Find all .rs files
fd -H                     # Include hidden files
fd -t d                   # Only directories
fd "test" -x rm           # Find and delete
```

### fzf

Interactive filtering:

| Binding | Action |
|---------|--------|
| `Ctrl+T` | Fuzzy find files |
| `Ctrl+R` | Search history |
| `Alt+C` | cd into directory |
| `**<Tab>` | Trigger completion |

Example workflows:

```bash
vim $(fd -t f | fzf)                    # Open file in vim
kill -9 $(ps aux | fzf | awk '{print $2}')  # Kill process
git checkout $(git branch | fzf)        # Checkout branch
```

---

## Git Workflow

### Lazygit

Git TUI:

```bash
lg              # Open lazygit
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

### Delta

Syntax-highlighted diffs (automatic):

```bash
git diff        # Uses delta
git show        # Uses delta
git log -p      # Uses delta
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

### GitHub CLI

```bash
gh pr create    # Create pull request
gh pr view      # View current PR
gh pr checkout  # Checkout PR locally
gh issue list   # List issues
gh repo view -w # Open in browser
```

---

## Development Environments

### Direnv + Nix Flakes

Automatic per-project environments:

```bash
cd ~/projects/my-app
echo "use flake" > .envrc
direnv allow
```

Example `flake.nix`:

```nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { nixpkgs, ... }: let
    pkgs = nixpkgs.legacyPackages.aarch64-darwin;
  in {
    devShells.aarch64-darwin.default = pkgs.mkShell {
      packages = with pkgs; [ nodejs_22 postgresql_16 ];
      shellHook = ''echo "Dev environment loaded"'';
    };
  };
}
```

### Mise

Polyglot version manager:

```bash
mise install node@20      # Install
mise use -g node@22       # Set global default
mise use node@20          # Set for project (.mise.toml)
mise ls                   # List installed
mise current              # Show current versions
```

### Runtimes

| Language | Default | Switch |
|----------|---------|--------|
| Node.js | 22 LTS | `mise use node@20` |
| Java | Zulu 17 | `mise use java@11` |
| Python | 3.x | `mise use python@3.12` |
| Elixir | 1.18 | via nix |
| Rust | stable | via rust-overlay |
| Go | latest | via nix |

---

## System Monitoring

### Bottom

System monitor (`top` replacement):

```bash
top             # Opens bottom (alias)
btm             # Direct command
```

| Key | Action |
|-----|--------|
| `q` | Quit |
| `?` | Help |
| `e` | Expand widget |
| `/` | Search processes |
| `dd` | Kill process |
| `Tab` | Cycle widgets |

### Other Tools

```bash
procs           # Process viewer (ps replacement)
dust            # Disk usage by directory (du replacement)
duf             # Disk free space (df replacement)
bandwhich       # Network usage by process
```

---

## Cloud & Kubernetes

### AWS CLI

```bash
aws configure
aws s3 ls
aws ec2 describe-instances
```

### Kubernetes

```bash
kubectl get pods
kubectl logs -f <pod>
k9s                         # K8s TUI
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

### SOPS with Age

Secrets encrypted and safe to commit:

```bash
sops secrets/secrets.yaml   # Edit secrets
```

File format (decrypted view):

```yaml
api_key: my-secret-value
database:
  password: db-secret
```

Use in Nix:

```nix
sops.secrets.api_key = {};
# Access at: config.sops.secrets.api_key.path
```

Age key location: `~/.config/sops/age/keys.txt`

---

## macOS Integration

### Keyboard

- Fast key repeat (KeyRepeat: 2, InitialKeyRepeat: 15)
- No auto-correct, auto-capitalization, or smart quotes
- Full keyboard access (Tab through all controls)

### Dock

- Auto-hide with no delay
- No recent apps
- Fast animations

### Finder

- Show hidden files
- Show all file extensions
- Column view by default
- Full path in title bar

### Trackpad

- Tap to click
- Three-finger drag
- Two-finger right click

### Screenshots

- Location: `~/Pictures/Screenshots`
- Format: PNG
- No shadows

---

## Aliases Reference

### Modern Replacements

| Alias | Tool | Description |
|-------|------|-------------|
| `cat` | bat | Syntax highlighting |
| `grep` | ripgrep | Fast search |
| `find` | fd | Fast find |
| `du` | dust | Disk usage |
| `df` | duf | Disk free |
| `top` | bottom | System monitor |
| `dig` | doggo | DNS lookup |

### Navigation

| Alias | Action |
|-------|--------|
| `..` | `cd ..` |
| `...` | `cd ../..` |
| `....` | `cd ../../..` |
| `y` | yazi file manager |

### Nix

| Alias | Command |
|-------|---------|
| `nrs` | `darwin-rebuild switch --flake ~/.config/nix` |
| `nrb` | `darwin-rebuild build --flake ~/.config/nix` |
| `nfu` | `nix flake update` |
| `nsh` | `nix-shell` |
| `nsp` | `nix search nixpkgs` |

### Utilities

| Alias | Description |
|-------|-------------|
| `path` | Show PATH entries |
| `reload` | Source ~/.zshrc |
| `myip` | Show public IP |
| `ports` | Show listening ports |
| `weather` | Show weather |

---

## Quick Tips

### File Preview

```bash
bat file.rs              # Syntax highlighted
glow README.md           # Rendered markdown
hexyl binary.bin         # Hex view
```

### Data Processing

```bash
cat data.json | jq '.items[].name'   # JSON
yq '.services' docker-compose.yml     # YAML
mlr --csv filter '$age > 30' data.csv # CSV
```

### Performance

```bash
hyperfine 'fd' 'find .'  # Benchmark commands
tokei                    # Code statistics
```

### Terminal Recording

```bash
asciinema rec            # Start recording
asciinema play file.cast # Playback
```
