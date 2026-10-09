{ pkgs, lib, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    # compinit with plain defaults re-audits fpath and rewrites .zcompdump on
    # every startup (~450ms measured). Reuse the dump with -C and only do the
    # full (audited, regenerating) init when the dump is older than a day.
    completionInit = ''
      autoload -U compinit
      if [[ -n ''${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh-24) ]]; then
        compinit -C
      else
        compinit
      fi
    '';
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    plugins = [
      {
        name = "fzf-tab";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
      {
        name = "zsh-autopair";
        src = "${pkgs.zsh-autopair}/share/zsh/zsh-autopair";
      }
    ];

    history = {
      size = 10000000;
      save = 10000000;
      path = "$HOME/.zsh_history";
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      share = true;
      extended = true;
    };

    sessionVariables = {
      EDITOR = "vim";
      VISUAL = "vim";
      LANG = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/keys.txt";

      # `npm install -g` needs a user-writable prefix (the Nix store is
      # read-only). Its bin dir is appended to PATH below, after the Nix
      # profiles, so an npm global can never shadow a Nix-managed tool.
      NPM_CONFIG_PREFIX = "$HOME/.npm-global";

      # Pre-trust xsolis mise config (managed by home-manager via nix store
      # symlinks, which mise distrusts on every rebuild without this).
      MISE_TRUSTED_CONFIG_PATHS = "$HOME/xsolis";

      # PATH additions (minimal - nix handles most tools). mise shims are
      # deliberately absent: mise activates via direnv (`use mise` in
      # ~/xsolis/.envrc), and global shims would shadow nix-managed
      # node/jq/python/helm with per-exec mise resolution.
      PATH = "$HOME/.local/bin:$HOME/.dotnet/tools:$HOME/.config/jetbrains:$PATH:$HOME/.npm-global/bin";
    };

    # oh-my-zsh was removed after measuring: it cost ~145ms of ~340ms startup
    # (43%) while atuin history showed its aliases/functions used once in
    # 12.6k commands. Its useful pieces are covered natively: colored man
    # pages by MANPAGER=bat, git shortcuts by shellAliases below, docker
    # completions by the cached `docker completion zsh` in initContent.

    defaultKeymap = "emacs";

    initContent = lib.mkMerge [
      # Before compinit (home-manager runs compinit at order 550): put
      # docker's own completion into fpath. Docker lives outside nix
      # (Docker Desktop); the oh-my-zsh docker plugin used to provide this.
      # Regenerated only when the docker binary is newer than the cache.
      (lib.mkOrder 400 ''
        if (( $+commands[docker] )); then
          if [[ ! -f ~/.cache/zsh/completions/_docker || $commands[docker] -nt ~/.cache/zsh/completions/_docker ]]; then
            mkdir -p ~/.cache/zsh/completions
            docker completion zsh > ~/.cache/zsh/completions/_docker 2>/dev/null || true
          fi
          fpath+=(~/.cache/zsh/completions)
        fi
      '')
      # devenv: enter a project's shell on `cd` into a directory with a
      # devenv.nix (trust it once with `devenv allow`). The hook script is
      # baked at build time, like LS_COLORS below, to keep startup fast.
      (lib.mkOrder 1500 ''
        source ${
          pkgs.runCommand "devenv-hook.zsh" { } ''
            HOME=$TMPDIR ${pkgs.devenv}/bin/devenv hook zsh > $out
          ''
        }
      '')
      ''
        # ── Shell behavior (formerly via oh-my-zsh) ─────────────────
        setopt AUTO_CD              # `dirname` alone cds into it
        setopt INTERACTIVE_COMMENTS # Allow # comments on the command line

        # ── Directory stack ─────────────────────────────────────────
        setopt AUTO_PUSHD           # cd automatically pushes to stack
        setopt PUSHD_IGNORE_DUPS    # No duplicates in stack
        setopt PUSHD_SILENT         # Don't print stack on every cd

        # LS_COLORS baked at build time — vivid's output is deterministic for
        # a given version + theme, so generate it once in a derivation instead
        # of spawning vivid on every shell startup.
        source ${
          pkgs.runCommand "vivid-ls-colors.zsh" { } ''
            printf 'export LS_COLORS=%q\n' "$(${pkgs.vivid}/bin/vivid generate snazzy)" > $out
          ''
        }

        # ── Completion styling ──────────────────────────────────────
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
        zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
        zstyle ':completion:*' group-name '''
        zstyle ':completion:*:descriptions' format '[%d]'

        # ── fzf-tab settings ────────────────────────────────────────
        zstyle ':fzf-tab:*' fzf-flags --height=50% --layout=reverse --border=rounded
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --level=2 --icons --color=always $realpath'
        zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --style=numbers --color=always --line-range :200 $realpath 2>/dev/null || eza --icons --color=always $realpath 2>/dev/null'

        # Homebrew
        if [[ -f /opt/homebrew/bin/brew ]]; then
          eval "$(/opt/homebrew/bin/brew shellenv)"
        fi

        # Better history search with arrow keys
        autoload -U up-line-or-beginning-search down-line-or-beginning-search
        zle -N up-line-or-beginning-search
        zle -N down-line-or-beginning-search
        bindkey "^[[A" up-line-or-beginning-search
        bindkey "^[[B" down-line-or-beginning-search

        # Edit command line in $EDITOR
        autoload -U edit-command-line
        zle -N edit-command-line
        bindkey '^x^e' edit-command-line

        # Word navigation
        bindkey '^[[1;5C' forward-word   # Ctrl+Right
        bindkey '^[[1;5D' backward-word  # Ctrl+Left
      ''
    ];

    shellAliases = {
      # Navigation (eza aliases handled by programs.eza)
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      tree = "eza --tree --icons";

      # Modern replacements
      grep = "rg";
      cat = "bat";
      find = "fd";
      du = "dust";
      df = "duf";
      ps = "procs";
      top = "btm";
      htop = "btm";
      dig = "doggo";

      # Git shortcuts
      g = "git";
      gs = "git status";
      ga = "git add";
      gaa = "git add --all";
      gc = "git commit";
      gcm = "git commit -m";
      gca = "git commit --amend";
      gp = "git push";
      gpf = "git push --force-with-lease";
      gl = "git pull";
      gd = "git diff";
      gds = "git diff --staged";
      gco = "git checkout";
      gcb = "git checkout -b";
      gb = "git branch";
      glog = "git log --oneline --graph --decorate";

      # Nix/Darwin (nh gives pretty output with diffs)
      nrs = "nh darwin switch ~/.config/nix";
      nrb = "nh darwin build ~/.config/nix";
      nfu = "nix flake update --flake ~/.config/nix";
      nup = "nix flake update --flake ~/.config/nix && nh darwin switch ~/.config/nix";
      nfc = "nix flake check ~/.config/nix";
      # Prune old generations (keep 3 / last 7d), then hardlink-dedup the
      # store. No GC here: Determinate Nixd collects garbage on its own.
      ngc = "nh clean all --keep 3 --keep-since 7d --no-gc && nix store optimise";
      # Brew upgrades are explicit; darwin-rebuild never touches them.
      bwu = "brew update && brew upgrade";
      nsh = "nix-shell";
      nsp = "nix search nixpkgs";

      # Misc
      mkdir = "mkdir -pv";
      cp = "cp -iv";
      mv = "mv -iv";
      rm = "rm -v";
      path = "echo $PATH | tr ':' '\\n'";
      reload = "source ~/.zshrc";
      weather = "curl wttr.in";
      myip = "curl ifconfig.me";
      ports = "lsof -iTCP -sTCP:LISTEN -n -P";

      # Directory stack
      d = "dirs -v | head -20";

      # Tools
      zj = "zellij";
      tm = "tmux";
      ta = "tmux attach -t";
      tn = "tmux new -s";
      tls = "tmux list-sessions";
    };
  };
}
