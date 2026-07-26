# SSH configuration with Bitwarden SSH Agent + traditional key fallback
#
# Priority:
# 1. Bitwarden SSH Agent (via SSH_AUTH_SOCK set in bitwarden.nix)
# 2. Traditional keys in ~/.ssh/ (always available as fallback)
# 3. macOS Keychain integration
{ ... }: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      # Default for all hosts (upstream ssh_config directive names)
      "*" = {
        # Traditional key as fallback when Bitwarden unavailable
        IdentityFile = "~/.ssh/id_ed25519";
        AddKeysToAgent = "yes";
        ForwardAgent = true;
        # macOS Keychain integration for traditional keys
        UseKeychain = true;
      };
    };
  };
}
