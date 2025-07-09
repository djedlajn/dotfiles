# Bitwarden SSH Agent configuration with fallback to system agent
#
# Prerequisites:
# 1. Install Bitwarden desktop app (DMG via homebrew)
# 2. Enable SSH Agent in Bitwarden: Settings > SSH Agent > Enable
# 3. Import or generate Ed25519 SSH keys in Bitwarden
# 4. Enable "Use for SSH agent" on each key item
# 5. Add the public key to GitHub as a "Signing Key"
#
# Fallback behavior:
#   - If Bitwarden socket exists → use Bitwarden SSH agent
#   - Otherwise → fall back to macOS system SSH agent
#   - Traditional keys in ~/.ssh/ always available as IdentityFile fallback
{ config, lib, ... }:
let
  homeDir = config.home.homeDirectory;
  bitwardenSocket = "${homeDir}/.bitwarden-ssh-agent.sock";
  systemSocket = "/private/tmp/com.apple.launchd.*/Listeners";
in
{
  # Shell initialization for SSH_AUTH_SOCK with fallback
  # This runs in zsh to set the agent socket dynamically
  programs.zsh.initContent = ''
    # SSH Agent: Bitwarden primary, macOS system fallback
    if [[ -S "${bitwardenSocket}" ]]; then
      export SSH_AUTH_SOCK="${bitwardenSocket}"
    elif [[ -n "$SSH_AUTH_SOCK" ]] && [[ -S "$SSH_AUTH_SOCK" ]]; then
      : # Keep existing socket (e.g., from ssh-agent or macOS)
    else
      # Try to find macOS launchd socket
      _sock=$(find /private/tmp -name "Listeners" -user "$USER" 2>/dev/null | head -1)
      [[ -S "$_sock" ]] && export SSH_AUTH_SOCK="$_sock"
      unset _sock
    fi
  '';

  # Create allowed_signers file for SSH signature verification
  # Format: <email> namespaces="git" <public-key>
  home.file.".ssh/allowed_signers".text = ''
    hi@uros.dev namespaces="git" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHmdchtcmbOwtdU4ZBlXDvl8fXNhpRqerZztq/YjOUuL
  '';
}
