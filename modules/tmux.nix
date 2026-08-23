{ pkgs, ... }: {
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";

    # C-Space instead of C-b or C-a: the shell uses the emacs keymap
    # (modules/shell.nix), where both C-a and C-b are line-editing keys.
    prefix = "C-Space";

    baseIndex = 1; # Windows/panes start at 1 — matches the number row
    escapeTime = 10; # Don't swallow Esc in vim/neovim
    historyLimit = 50000;
    keyMode = "vi";
    mouse = true;
    clock24 = true;
    terminal = "tmux-256color";

    extraConfig = ''
      # ── Terminal capabilities ───────────────────────────────────
      # Ghostty sets TERM=xterm-ghostty; advertise truecolor and
      # undercurl for whatever outer terminal is in use.
      set -as terminal-features ",*:RGB"
      set -as terminal-overrides ",*:Smulx=\E[4::%p1%dm"
      set -as terminal-overrides ",*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m"
      set -g focus-events on
      set -g set-clipboard on

      # ── Windows & panes ─────────────────────────────────────────
      setw -g pane-base-index 1
      set -g renumber-windows on
      set -g automatic-rename on
      set -g set-titles on
      set -g set-titles-string "#S · #W"
      set -g display-time 2000

      # Splits keep the current directory
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      # vi-style pane movement and resizing
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded"

      # ── Copy mode (vi) ──────────────────────────────────────────
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send -X copy-pipe-and-cancel "pbcopy"
      bind -T copy-mode-vi Escape send -X cancel

      # ── Catppuccin Mocha ────────────────────────────────────────
      # base #1e1e2e  mantle #181825  surface0 #313244
      # text #cdd6f4  subtext0 #a6adc8  overlay0 #6c7086
      # mauve #cba6f7  blue #89b4fa  green #a6e3a1  peach #fab387
      set -g status-position top
      set -g status-style "bg=#181825,fg=#cdd6f4"
      set -g status-left-length 40
      set -g status-right-length 60
      set -g status-left "#[bg=#cba6f7,fg=#1e1e2e,bold] #S #[bg=#181825,fg=#cba6f7]"
      set -g status-right "#[fg=#6c7086]#{?client_prefix,#[fg=#fab387]PREFIX ,}#[fg=#a6adc8]%H:%M #[bg=#313244,fg=#89b4fa] #h "

      setw -g window-status-format "#[fg=#6c7086] #I:#W#{?window_zoomed_flag, ,} "
      setw -g window-status-current-format "#[bg=#313244,fg=#89b4fa,bold] #I:#W#{?window_zoomed_flag, ,} "
      setw -g window-status-activity-style "fg=#f9e2af"

      set -g pane-border-style "fg=#313244"
      set -g pane-active-border-style "fg=#cba6f7"
      set -g message-style "bg=#313244,fg=#cdd6f4"
      set -g mode-style "bg=#585b70,fg=#cdd6f4"
    '';
  };
}
