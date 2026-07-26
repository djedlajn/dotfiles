# Quick Reference

## Keybindings

### Shell

| Key | Action |
|-----|--------|
| `Tab` | Fuzzy completion (fzf-tab + previews) |
| `Ctrl+R` | History search (atuin) |
| `Ctrl+T` | File picker (fzf) |
| `Alt+C` | Directory picker (fzf) |
| `Ctrl+X Ctrl+E` | Edit command in $EDITOR |

### Ghostty

| Key | Action |
|-----|--------|
| `` Cmd+` `` | Quick terminal (Quake dropdown) |
| `Cmd+T / Cmd+W` | New tab / close |
| `Cmd+Shift+Enter / -` | Split right / down |
| `Cmd+Opt+Arrow` | Navigate splits |

### Yazi (`y`)

`h/j/k/l` navigate, `y/x/p/d` copy/cut/paste/delete, `a` create, `r` rename, `/` find, `Ctrl+G` lazygit

### Lazygit (`lg`)

`Ctrl+O` open in browser, `O` create PR, `Ctrl+B` browse commit, `F` fetch all

---

## Aliases

```bash
# Replacements
cat=bat  grep=rg  find=fd  du=dust  df=duf  ps=procs  top=btm  dig=doggo

# Git
g gs ga gaa gc gcm gca gp gpf gl gd gds gco gcb gb glog

# Nix
nrs="nh darwin switch"  nrb="nh darwin build"  nfu="nix flake update"
nfc="nix flake check"   ngc="nh clean all + nix store optimise"

# Tools
y=yazi  zj=zellij  lg=lazygit  d="dirs -v"

# Xsolis (work)
xsl-login="aws sso login --sso-session xsolis"  xsl-whoami="aws sts get-caller-identity"
assume="source assume"
```

---

## Tools

| Category | Tools |
|----------|-------|
| Core CLI | fd, jq, yq, sd, choose, curl, wget, aria2 |
| Monitoring | bottom, procs, dust, duf, bandwhich, trippy |
| Dev | jujutsu, difftastic, pre-commit, gh, tokei, hyperfine, television |
| AI | claude-code, herdr, opencode (brew) |
| HTTP | xh, doggo, dnsmasq, cloudflared |
| Cloud/K8s | awscli2, aws-nuke, packer, kubectl, helm, k9s, stern, kubectx |
| Formatters | stylua, shfmt, shellcheck, nixfmt |
| Nix | nh, nvd, nix-tree, treefmt (via nix fmt) |
| Security | bitwarden-cli, minisign, sops, age |
| Misc | ouch, vivid, silicon, asciinema, fastfetch, rclone, mise, glow, hexyl, miller |
| Languages | Rust, Go, Node 24, Bun, Python 3, Elixir 1.18, Java 17 |
| Work (xsolis) | dotnet-sdk 8, granted, liquibase, xsolis-* helper scripts, claude-xsolis |
