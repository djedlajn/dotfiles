# Git configuration with SSH commit signing
{ config, pkgs, ... }: {
  programs.git = {
    enable = true;

    # Core settings (new API)
    settings = {
      user = {
        name = "Uros Karic";
        email = "hi@uros.dev";
        signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHmdchtcmbOwtdU4ZBlXDvl8fXNhpRqerZztq/YjOUuL";
      };

      # SSH commit signing (modern alternative to GPG)
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed_signers";
      commit.gpgsign = true;
      tag.gpgsign = true;

      alias = {
        co = "checkout";
        br = "branch";
        ci = "commit";
        st = "status";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        graph = "log --oneline --graph --decorate --all";
        amend = "commit --amend --no-edit";
        undo = "reset --soft HEAD~1";
        ignore = "!gi() { curl -sL https://www.toptal.com/developers/gitignore/api/$@ ;}; gi";
      };

      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      rebase.autoStash = true;
      rerere.enabled = true;
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
      diff.algorithm = "histogram";
      credential.helper = "/opt/homebrew/bin/gh auth git-credential";
      core = {
        editor = "vim";
        autocrlf = "input";
      };
      fetch.prune = true;
      branch.sort = "-committerdate";
    };

    ignores = [
      # macOS
      ".DS_Store"
      ".DS_Store?"
      "._*"
      ".Spotlight-V100"
      ".Trashes"
      "ehthumbs.db"
      "Thumbs.db"

      # IDEs
      ".vscode/"
      ".idea/"
      "*.swp"
      "*.swo"
      "*~"

      # Node
      "node_modules/"
      "npm-debug.log*"
      "yarn-debug.log*"
      "yarn-error.log*"

      # Environment
      ".env"
      ".env.local"
      ".env.*.local"

      # Logs
      "logs/"
      "*.log"

      # Coverage
      "coverage/"

      # Build
      "dist/"
      "build/"

      # Claude
      "**/.claude/settings.local.json"
    ];

    includes = [
      {
        condition = "gitdir/i:~/greenlight/";
        path = "~/.gitconfig-greenlight";
      }
    ];
  };

  # Delta - separate program now
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      light = false;
      side-by-side = true;
      line-numbers = true;
      syntax-theme = "catppuccin-mocha";
      # Catppuccin Mocha diff colors
      minus-style = "syntax #53394c";
      minus-emph-style = "syntax #894662";
      plus-style = "syntax #404f4a";
      plus-emph-style = "syntax #4e7a5e";
      line-numbers-minus-style = "#f38ba8";
      line-numbers-plus-style = "#a6e3a1";
      line-numbers-zero-style = "#6c7086";
    };
  };
}
