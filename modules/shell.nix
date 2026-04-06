{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
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
      HOMEBREW_NO_AUTO_UPDATE = "1";
      RIPGREP_CONFIG_PATH = "$HOME/.config/ripgrep/config";
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/keys.txt";

      # PATH additions (minimal - nix handles most tools)
      PATH = "$HOME/.local/bin:$HOME/.local/share/mise/shims:$HOME/.config/jetbrains:$PATH";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
        "brew"
        "macos"
        "colored-man-pages"
        "command-not-found"
        "kubectl"
      ];
    };

    defaultKeymap = "emacs";

    initContent = ''
      # ── Directory stack ─────────────────────────────────────────
      setopt AUTO_PUSHD           # cd automatically pushes to stack
      setopt PUSHD_IGNORE_DUPS    # No duplicates in stack
      setopt PUSHD_SILENT         # Don't print stack on every cd

      # LS_COLORS must be evaluated at shell startup
      export LS_COLORS="$(vivid generate snazzy)"

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

      # Lazygit with directory change on exit
      lg() {
        export LAZYGIT_NEW_DIR_FILE=~/.lazygit/newdir
        command lazygit "$@"
        if [ -f $LAZYGIT_NEW_DIR_FILE ]; then
          cd "$(cat $LAZYGIT_NEW_DIR_FILE)"
          rm -f $LAZYGIT_NEW_DIR_FILE > /dev/null
        fi
      }
    '';

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
      nfc = "nix flake check ~/.config/nix";
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
      tv = "television";
    };
  };
} 