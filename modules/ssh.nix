# SSH configuration with Bitwarden SSH Agent + traditional key fallback
#
# Priority:
# 1. Bitwarden SSH Agent (via SSH_AUTH_SOCK set in bitwarden.nix)
# 2. Traditional keys in ~/.ssh/ (always available as fallback)
# 3. macOS Keychain integration
{ config, ... }: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    extraConfig = ''
      # macOS Keychain integration for traditional keys
      UseKeychain yes
      AddKeysToAgent yes

      # Forward agent for remote access
      ForwardAgent yes
    '';

    matchBlocks = {
      # Default for all hosts
      "*" = {
        # Traditional key as fallback when Bitwarden unavailable
        identityFile = "~/.ssh/id_ed25519";
      };

    };
  };
}
