# Capabilities

Quick reference for tools, keybindings, and config. Theme: **Catppuccin Mocha** everywhere.

---

## Shell (Zsh)

**Plugins:** oh-my-zsh (git, docker, brew, macos, kubectl), fzf-tab, zsh-autopair, syntax-highlighting, autosuggestions

| Binding | Action |
|---------|--------|
| `Tab` | Fuzzy completion (fzf-tab with previews) |
| `Ctrl+R` | Atuin history search (fuzzy) |
| `Ctrl+T` | fzf file picker |
| `Alt+C` | fzf cd into directory |
| `Ctrl+X Ctrl+E` | Edit command in `$EDITOR` |
| `Up/Down` | Prefix-based history search |

**Directory stack:** `AUTO_PUSHD` is on — every `cd` pushes to a stack. `d` shows the stack, `cd -N` jumps back.

### Aliases

```bash
# Modern replacements
cat=bat  grep=rg  find=fd  du=dust  df=duf  ps=procs  top=btm  dig=doggo

# Git
g gs ga gaa gc gcm gca gp gpf gl gd gds gco gcb gb glog

# Nix (uses nh for pretty output with diffs)
nrs="nh darwin switch"  nrb="nh darwin build"
nfu="nix flake update"  nfc="nix flake check"

# Tools
y=yazi  zj=zellij  tv=television  lg=lazygit  d="dirs -v"
```

---

## Terminal (Ghostty)

| Keybinding | Action |
|------------|--------|
| `` Cmd+` `` | Quick terminal (Quake dropdown) |
| `Cmd+T/W` | New tab / close |
| `Cmd+Shift+Enter/-` | Split right / down |
| `Cmd+Opt+Arrow` | Navigate splits |

---

## Prompt (Starship)

Transient prompt — past lines collapse to `󱍢`, current line shows full context.

```
󱍢  ~/.config/nix  main !+                          22
```

Left: nix_shell, character, directory, git | Right: language versions

---

## File Listing (Eza)

Replaces `ls` with git status, icons, hyperlinks, color-scaled sizes, relative timestamps, directories first.

---

## History (Atuin)

Fuzzy search, compact style, 25-line preview. Secrets auto-filtered. Tracks subcommands for git, docker, kubectl, nix, cargo, etc.

---

## File Manager (Yazi)

Vim keybindings. Shell wrapper: `y` (cds to last dir on exit).

| Key | Action |
|-----|--------|
| `h/j/k/l` | Navigate |
| `y/x/p/d` | Copy/cut/paste/delete |
| `a/r` | Create/rename |
| `/` | Find, `f` filter |
| `,m/n/s` | Sort by modified/name/size |
| `gh/gc/gd` | Goto home/config/downloads |
| `Ctrl+G` | Open lazygit |

---

## Git

**Config:** SSH signing, rebase on pull, auto-setup remote, rerere, histogram diff, delta side-by-side diffs.

**Lazygit:** Full TUI. `Ctrl+O` open in browser, `O` create PR, `Ctrl+B` browse commit.

**Delta:** Side-by-side, line numbers, catppuccin syntax theme.

---

## Fuzzy Finding

- **fzf** — `Ctrl+T` files, `Alt+C` dirs, `Ctrl+R` history (deferred to atuin)
- **fzf-tab** — All tab completions go through fzf with previews
- **television** (`tv`) — Standalone fuzzy finder TUI
- **zoxide** — Smart `cd` with frecency. `cdi` for interactive selection

---

## Window Manager (AeroSpace)

Disabled by default. i3-like tiling when enabled.

`Alt+H/J/K/L` focus, `Alt+Shift+H/J/K/L` move, `Alt+1-9` workspaces, `Alt+F` fullscreen.

---

## Development

**Direnv:** Auto-loads `.envrc` in `~/projects`, `~/code`. Supports `use flake`, `layout node`, `layout python_venv`, `use mise`.

**Packages:** jujutsu, difftastic, pre-commit, gh, tokei, hyperfine, dive, mkcert, graphviz

---

## Nix Management

```bash
nfu          # Update flake inputs (nixpkgs, home-manager, etc.)
nrs          # Rebuild & switch (via nh, shows diffs)
nrb          # Build only (via nh)
nfc          # Flake check
```

**Tools:** nh, nvd, nix-tree, nixfmt, treefmt

---

## Secrets (SOPS)

Age-encrypted secrets in `secrets/secrets.yaml`. Key: `~/.config/sops/age/keys.txt`.

```bash
sops secrets/secrets.yaml   # Edit
```

---

## SSH

Bitwarden SSH Agent (primary) with `~/.ssh/id_ed25519` fallback. Keychain integration, agent forwarding enabled. SSH commit signing.

---

## Installed Tools

| Category | Tools |
|----------|-------|
| Core CLI | fd, jq, yq, sd, choose, curl, wget, aria2 |
| Monitoring | bottom, procs, dust, duf, bandwhich, trippy |
| Task runners | just, watchexec, navi, gnumake |
| HTTP/Network | xh, doggo, dnsmasq, cloudflared |
| Text/Data | glow, hexyl, miller |
| Cloud | awscli2, aws-nuke, packer |
| Kubernetes | kubectl, helm, k9s, stern, kubectx |
| Security | bitwarden-cli, minisign, sops, age |
| Formatters | stylua, shfmt, shellcheck, nixfmt |
| Misc | ouch, vivid, silicon, asciinema, fastfetch, rclone, mise, television |
| Languages | Rust, Go, Node 22, Bun, Python 3, Elixir 1.18, Java 17 (Zulu) |
