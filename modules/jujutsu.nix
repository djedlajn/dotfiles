# Jujutsu (jj) VCS
{ config, ... }:
{
  programs.jujutsu = {
    enable = true;

    settings = {
      # Same identity as git so jj commits on colocated repos match
      user = {
        inherit (config.programs.git.settings.user) name email;
      };
    };
  };
}
