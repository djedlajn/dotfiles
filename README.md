# dotfiles

Declarative macOS system configuration using [Nix Flakes](https://nixos.wiki/wiki/Flakes), [nix-darwin](https://github.com/nix-darwin/nix-darwin), and [home-manager](https://github.com/nix-community/home-manager).

## Structure

```
flake.nix              # Inputs & system definition
hosts/                 # Per-machine config (packages, homebrew, macOS defaults)
home/                  # User config & module imports
modules/               # Tool configurations (one file per tool)
secrets/               # Encrypted secrets (sops + age)
docs/                  # Quick reference
```

## Setup

```bash
# Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Clone & apply (first activation; nix-darwin is not on PATH yet)
git clone https://github.com/djedlajn/dotfiles ~/.config/nix
cd ~/.config/nix && sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .#Uross-MacBook-Pro
```

Subsequent rebuilds use `nrs` (nh handles privilege escalation).

## Day-to-day

```bash
nfu       # Update all flake inputs
nrs       # Rebuild & switch (nh, with diffs)
nrb       # Build without switching
nfc       # nix flake check — builds the system + verifies formatting
ngc       # Clean old generations + GC + dedup the store
nix fmt   # Format all .nix files (nixfmt via treefmt)
```

Background garbage collection runs automatically (Determinate Nixd); `ngc` is
for reclaiming old profile generations on demand.

## Stack

**Terminal:** Ghostty, Zellij, tmux, Starship

**Shell:** Zsh + oh-my-zsh, fzf-tab, zsh-autopair, atuin, zoxide, direnv

**Files:** eza, fd, ripgrep, bat, yazi

**Git:** lazygit, delta, jujutsu, difftastic, gh

**AI:** Claude Code + Codex (declarative via claude-code-nix / codex-cli-nix, hourly updates + cachix), herdr, opencode + omp (brew)

**Languages:** Rust (overlay), Go, Node 24, Bun, Python 3 + uv, Elixir 1.18, Java 17

**Cloud:** awscli2, kubectl, helm, k9s, stern, kubectx, packer, cloudflared

**Security:** Bitwarden SSH Agent, sops + age, SSH commit signing (GPG inside ~/xsolis), Touch ID sudo

**macOS:** Raycast, fast key repeat, auto-hide dock, Finder tweaks

**Theme:** Catppuccin Mocha (everywhere)

## Docs

- [Quick Reference](docs/CAPABILITIES.md) &mdash; keybindings, aliases, tools

## License

MIT
