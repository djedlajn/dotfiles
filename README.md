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

# Clone & apply
git clone https://github.com/djedlajn/dotfiles ~/.config/nix
cd ~/.config/nix && darwin-rebuild switch --flake .
```

## Day-to-day

```bash
nfu     # Update all flake inputs
nrs     # Rebuild & switch (nh, with diffs)
nrb     # Build without switching
```

## Stack

**Terminal:** Ghostty, Zellij, Starship (transient prompt)

**Shell:** Zsh + oh-my-zsh, fzf-tab, zsh-autopair, atuin, zoxide, direnv

**Files:** eza, fd, ripgrep, bat, yazi

**Git:** lazygit, delta, jujutsu, difftastic, gh

**Languages:** Rust (overlay), Go, Node 24, Bun, Python 3 + uv, Elixir 1.18, Java 17

**Cloud:** awscli2, kubectl, helm, k9s, stern, kubectx, packer, cloudflared

**Security:** Bitwarden SSH Agent, sops + age, SSH commit signing, Touch ID sudo

**macOS:** AeroSpace (optional), Raycast, fast key repeat, auto-hide dock, Finder tweaks

**Theme:** Catppuccin Mocha (everywhere)

## Docs

- [Quick Reference](docs/CAPABILITIES.md) &mdash; keybindings, aliases, tools

## License

MIT
