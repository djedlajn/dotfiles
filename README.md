# dotfiles

Declarative macOS system configuration using [Nix Flakes](https://nixos.wiki/wiki/Flakes), [nix-darwin](https://github.com/nix-darwin/nix-darwin), and [home-manager](https://github.com/nix-community/home-manager).

## Structure

```
flake.nix              # Inputs & system definition
hosts/                 # Per-machine config (system packages, homebrew, fonts)
home/                  # User config & module imports
modules/               # Tool configurations (one file per tool)
secrets/               # Encrypted secrets (sops + age)
docs/                  # Quick reference
.github/workflows/     # CI: flake check on push/PR, weekly flake.lock PRs
```

## Setup

```bash
# Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Install Homebrew (nix-darwin manages its packages, not Homebrew itself)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Clone
git clone https://github.com/djedlajn/dotfiles ~/.config/nix
```

Put the age key at `~/.config/sops/age/keys.txt` before the first switch, so
sops-nix can decrypt secrets. If it is lost, see [Recovery](#recovery).

```bash
# First activation (nix-darwin is not on PATH yet)
cd ~/.config/nix && sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .#Uross-MacBook-Pro
```

Subsequent rebuilds use `nrs` (nh handles privilege escalation).

## Day-to-day

```bash
nup       # Update flake inputs, then rebuild & switch
nfu       # Update all flake inputs
nrs       # Rebuild & switch (nh, with diffs)
nrb       # Build without switching
nfc       # nix flake check — builds the system + verifies formatting
ngc       # Prune old generations + dedup the store (no GC)
bwu       # brew update && brew upgrade (rebuilds never upgrade brew)
nix fmt   # Format all .nix files (nixfmt via treefmt)
```

Determinate Nixd collects store garbage on its own; `ngc` and a weekly
`nh clean` launchd job only remove old generations so their paths become
collectable.

### Where tools come from

- **Nix** (`home/kadza.nix`, `hosts/`): everything that is in nixpkgs and
  cached. Prefer this.
- **Homebrew** (`hosts/Uross-MacBook-Pro.nix`): GUI apps, apps that update
  themselves (Ghostty tip, Raycast), and omp. Cleanup is `zap`, so anything
  not declared is removed on switch.
- **npm globals**: `npm i -g` installs into `~/.npm-global`, whose bin dir is
  last on PATH. A global can never shadow a Nix-managed tool.

### CI

`check.yml` runs `nix flake check` on macOS for every push and PR.
`update-flake-lock.yml` opens a flake.lock PR every Monday. It needs the
`GH_TOKEN_FOR_UPDATES` repo secret (fine-grained PAT, Contents + Pull
requests read/write) so CI runs on that PR.

## Secrets

`secrets/secrets.yaml` is encrypted with sops for two age recipients (see
`.sops.yaml`): the age key in `~/.config/sops/age/keys.txt` and the SSH key
`~/.ssh/id_ed25519` (also stored in Bitwarden). Either one decrypts it.

`modules/sops.nix` declares every secret. On login and on every switch,
sops-nix decrypts them to a RAM disk and links them into place:

| Target | How |
|---|---|
| `~/.npmrc`, `~/.config/rclone/rclone.conf` | Rendered from `sops.templates` |
| `~/.ssh/id_ed25519`, `~/.config/xsolis/*` tokens | Single secrets at a fixed `path` |
| Context7 key | `~/.config/sops-nix/secrets/context7_api_key`, read by `opencode.json` via `{file:…}` |

Managed files are read-only symlinks. Tools that rewrite their own config
(opencode, OAuth rclone remotes) stay app-owned.

```bash
sops secrets/secrets.yaml   # edit values, then:
nrs                         # sops-nix reads the copy in the Nix store
```

To add a secret, add the key with `sops`, declare it in `modules/sops.nix`,
then `nrs`.

### Recovery

If `keys.txt` is lost, use the SSH key from Bitwarden to re-key the file for a
new age key:

```bash
# 1. Export id_ed25519 from Bitwarden to ~/.ssh/id_ed25519 (mode 600)
# 2. Create a new age key and put its public key in .sops.yaml (replace &kadza)
age-keygen -o ~/.config/sops/age/keys.txt
# 3. Re-encrypt for the recipients now in .sops.yaml
SOPS_AGE_SSH_PRIVATE_KEY_FILE=~/.ssh/id_ed25519 sops updatekeys -y secrets/secrets.yaml
# 4. Switch; sops-nix replaces ~/.ssh/id_ed25519 with its managed copy
```

## Stack

**Terminal:** Ghostty (brew, tip), Zellij, tmux, Starship

**Shell:** Zsh, fzf-tab, zsh-autopair, atuin, zoxide, direnv

**Files:** eza, fd, ripgrep, bat, yazi

**Git:** lazygit, delta, jujutsu, difftastic, gh

**AI:** Claude Code + Codex (declarative via claude-code-nix / codex-cli-nix, hourly updates + cachix), herdr, opencode, omp (brew)

**Languages:** Rust (overlay), Go, Node 24 + pnpm/yarn, Bun, Python 3 + uv, Elixir 1.18, Java 17

**Cloud:** awscli2, kubectl, helm, k9s, stern, kubectx, packer, cloudflared, wrangler

**Security:** Bitwarden SSH Agent, sops-nix + age (SSH key as backup recipient), SSH commit signing (GPG inside ~/xsolis), Touch ID sudo

**macOS:** Raycast, fast key repeat, auto-hide dock, Finder tweaks

**Theme:** Catppuccin Mocha (everywhere)

## Docs

- [Quick Reference](docs/CAPABILITIES.md) &mdash; keybindings, aliases, tools

## License

MIT
