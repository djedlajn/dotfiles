{ ... }: {
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;

    defaultCommand = "fd --type f --hidden --follow --exclude .git";

    defaultOptions = [
      "--height 50%"
      "--layout=reverse"
      "--border=rounded"
      "--info=inline"
      "--preview 'bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || cat {}'"
      "--preview-window=right:50%:wrap"
      "--bind=ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up"
      "--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8"
      "--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc"
      "--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
    ];

    # Alt+C: cd into selected directory
    changeDirWidget = {
      command = "fd --type d --hidden --follow --exclude .git";
      options = [
        "--preview 'eza --tree --level=2 --icons --color=always {} | head -100'"
      ];
    };

    # Ctrl+T: paste selected file path
    fileWidget = {
      command = "fd --type f --hidden --follow --exclude .git";
      options = [
        "--preview 'bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || cat {}'"
      ];
    };

    # Ctrl+R belongs to atuin (the atuin module)
    historyWidget.command = "";
  };
}
