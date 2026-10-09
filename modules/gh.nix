# GitHub CLI. Only static preferences are declared: hosts.yml (auth tokens)
# stays runtime-owned by `gh auth login`.
{ ... }:
{
  programs.gh = {
    enable = true;

    # git.nix already sets gh as the global credential.helper (after the
    # system osxkeychain helper); HM's per-host helper would reset that chain
    # for github.com.
    gitCredentialHelper.enable = false;

    settings = {
      git_protocol = "https";
      prompt = "enabled";
      aliases.co = "pr checkout";
    };
  };
}
