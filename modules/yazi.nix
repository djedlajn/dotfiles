{ pkgs, ... }: {
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";

    settings = {
      manager = {
        show_hidden = true;
        sort_by = "natural";
        sort_dir_first = true;
        linemode = "size";
        show_symlink = true;
      };

      preview = {
        tab_size = 2;
        max_width = 1000;
        max_height = 1000;
        image_filter = "triangle";
        image_quality = 75;
        sixel_fraction = 15;
      };

      opener = {
        edit = [
          { run = "\${EDITOR:-vim} \"$@\""; block = true; for = "unix"; }
        ];
        open = [
          { run = "open \"$@\""; for = "macos"; }
        ];
      };
    };

    keymap = {
      manager.keymap = [
        { on = [ "<Esc>" ]; run = "escape"; desc = "Exit visual mode / clear selection"; }
        { on = [ "q" ]; run = "quit"; desc = "Quit"; }
        { on = [ "Q" ]; run = "quit --no-cwd-file"; desc = "Quit without changing directory"; }
        { on = [ "<C-q>" ]; run = "close"; desc = "Close tab"; }

        # Navigation
        { on = [ "k" ]; run = "arrow -1"; desc = "Move up"; }
        { on = [ "j" ]; run = "arrow 1"; desc = "Move down"; }
        { on = [ "K" ]; run = "arrow -5"; desc = "Move up 5"; }
        { on = [ "J" ]; run = "arrow 5"; desc = "Move down 5"; }
        { on = [ "g" "g" ]; run = "arrow -99999999"; desc = "Go to top"; }
        { on = [ "G" ]; run = "arrow 99999999"; desc = "Go to bottom"; }

        { on = [ "h" ]; run = "leave"; desc = "Go parent directory"; }
        { on = [ "l" ]; run = "enter"; desc = "Enter directory"; }
        { on = [ "<Enter>" ]; run = "open"; desc = "Open file"; }
        { on = [ "<C-Enter>" ]; run = "open --interactive"; desc = "Open interactively"; }

        { on = [ "H" ]; run = "back"; desc = "Go back"; }
        { on = [ "L" ]; run = "forward"; desc = "Go forward"; }

        # Selection
        { on = [ "<Space>" ]; run = [ "select --state=none" "arrow 1" ]; desc = "Toggle selection"; }
        { on = [ "v" ]; run = "visual_mode"; desc = "Visual mode"; }
        { on = [ "V" ]; run = "visual_mode --unset"; desc = "Visual mode (unset)"; }
        { on = [ "<C-a>" ]; run = "select_all --state=true"; desc = "Select all"; }
        { on = [ "<C-r>" ]; run = "select_all --state=none"; desc = "Invert selection"; }

        # Operations
        { on = [ "y" ]; run = "yank"; desc = "Yank (copy)"; }
        { on = [ "x" ]; run = "yank --cut"; desc = "Cut"; }
        { on = [ "p" ]; run = "paste"; desc = "Paste"; }
        { on = [ "P" ]; run = "paste --force"; desc = "Paste (overwrite)"; }
        { on = [ "d" ]; run = "remove"; desc = "Delete"; }
        { on = [ "D" ]; run = "remove --permanently"; desc = "Delete permanently"; }
        { on = [ "a" ]; run = "create"; desc = "Create file/directory"; }
        { on = [ "r" ]; run = "rename --cursor=before_ext"; desc = "Rename"; }

        # Find/Filter
        { on = [ "/" ]; run = "find --smart"; desc = "Find"; }
        { on = [ "?" ]; run = "find --previous --smart"; desc = "Find previous"; }
        { on = [ "n" ]; run = "find_arrow"; desc = "Next match"; }
        { on = [ "N" ]; run = "find_arrow --previous"; desc = "Previous match"; }
        { on = [ "f" ]; run = "filter --smart"; desc = "Filter"; }

        # Sorting
        { on = [ "," "m" ]; run = "sort modified --dir-first"; desc = "Sort by modified"; }
        { on = [ "," "M" ]; run = "sort modified --reverse --dir-first"; desc = "Sort by modified (reverse)"; }
        { on = [ "," "n" ]; run = "sort natural --dir-first"; desc = "Sort by name"; }
        { on = [ "," "N" ]; run = "sort natural --reverse --dir-first"; desc = "Sort by name (reverse)"; }
        { on = [ "," "s" ]; run = "sort size --dir-first"; desc = "Sort by size"; }
        { on = [ "," "S" ]; run = "sort size --reverse --dir-first"; desc = "Sort by size (reverse)"; }

        # Tabs
        { on = [ "t" ]; run = "tab_create --current"; desc = "New tab"; }
        { on = [ "1" ]; run = "tab_switch 0"; desc = "Tab 1"; }
        { on = [ "2" ]; run = "tab_switch 1"; desc = "Tab 2"; }
        { on = [ "3" ]; run = "tab_switch 2"; desc = "Tab 3"; }
        { on = [ "[" ]; run = "tab_switch -1 --relative"; desc = "Previous tab"; }
        { on = [ "]" ]; run = "tab_switch 1 --relative"; desc = "Next tab"; }

        # Goto
        { on = [ "g" "h" ]; run = "cd ~"; desc = "Go home"; }
        { on = [ "g" "c" ]; run = "cd ~/.config"; desc = "Go config"; }
        { on = [ "g" "d" ]; run = "cd ~/Downloads"; desc = "Go downloads"; }
        # Shell
        { on = [ ":" ]; run = "shell --interactive"; desc = "Shell command"; }
        { on = [ ";" ]; run = "shell --block --interactive"; desc = "Shell command (block)"; }
        { on = [ "." ]; run = "hidden toggle"; desc = "Toggle hidden"; }

        # Lazygit integration
        { on = [ "<C-g>" ]; run = "shell 'lazygit' --block --confirm"; desc = "Open lazygit"; }
      ];
    };

    # Catppuccin Mocha theme
    theme = {
      manager = {
        cwd = { fg = "#89b4fa"; };              # blue
        hovered = { bg = "#313244"; };          # surface0
        preview_hovered = { underline = true; };
        find_keyword = { fg = "#f9e2af"; bold = true; }; # yellow
        find_position = { fg = "#f5c2e7"; };    # pink
        marker_copied = { fg = "#a6e3a1"; };    # green
        marker_cut = { fg = "#f38ba8"; };       # red
        marker_marked = { fg = "#89dceb"; };    # sky
        marker_selected = { fg = "#cba6f7"; };  # mauve
        tab_active = { fg = "#1e1e2e"; bg = "#cba6f7"; }; # base, mauve
        tab_inactive = { fg = "#cdd6f4"; bg = "#45475a"; }; # text, surface1
        tab_width = 1;
        count_copied = { fg = "#1e1e2e"; bg = "#a6e3a1"; }; # base, green
        count_cut = { fg = "#1e1e2e"; bg = "#f38ba8"; };    # base, red
        count_selected = { fg = "#1e1e2e"; bg = "#cba6f7"; }; # base, mauve
        border_symbol = "│";
        border_style = { fg = "#6c7086"; };     # overlay0
      };

      status = {
        separator_open = "";
        separator_close = "";
        separator_style = { fg = "#45475a"; };  # surface1
        mode_normal = { fg = "#1e1e2e"; bg = "#89b4fa"; bold = true; }; # base, blue
        mode_select = { fg = "#1e1e2e"; bg = "#a6e3a1"; bold = true; }; # base, green
        mode_unset = { fg = "#1e1e2e"; bg = "#f5c2e7"; bold = true; };  # base, pink
        progress_label = { fg = "#cdd6f4"; bold = true; }; # text
        progress_normal = { fg = "#89b4fa"; bg = "#45475a"; }; # blue, surface1
        progress_error = { fg = "#f38ba8"; bg = "#45475a"; };  # red, surface1
        permissions_t = { fg = "#a6e3a1"; };    # green
        permissions_r = { fg = "#f9e2af"; };    # yellow
        permissions_w = { fg = "#f38ba8"; };    # red
        permissions_x = { fg = "#94e2d5"; };    # teal
        permissions_s = { fg = "#6c7086"; };    # overlay0
      };

      input = {
        border = { fg = "#89b4fa"; };           # blue
        title = {};
        value = {};
        selected = { reversed = true; };
      };

      select = {
        border = { fg = "#89b4fa"; };           # blue
        active = { fg = "#f5c2e7"; bold = true; }; # pink
        inactive = {};
      };

      tasks = {
        border = { fg = "#89b4fa"; };           # blue
        title = {};
        hovered = { fg = "#cba6f7"; underline = true; }; # mauve
      };

      which = {
        mask = { bg = "#313244"; };             # surface0
        cand = { fg = "#94e2d5"; };             # teal
        rest = { fg = "#6c7086"; };             # overlay0
        desc = { fg = "#f5c2e7"; };             # pink
        separator = "  ";
        separator_style = { fg = "#585b70"; };  # surface2
      };

      help = {
        on = { fg = "#94e2d5"; };               # teal
        run = { fg = "#f5c2e7"; };              # pink
        desc = { fg = "#6c7086"; };             # overlay0
        hovered = { bg = "#313244"; bold = true; }; # surface0
        footer = { fg = "#cdd6f4"; bg = "#45475a"; }; # text, surface1
      };

      notify = {
        title_info = { fg = "#89b4fa"; };       # blue
        title_warn = { fg = "#f9e2af"; };       # yellow
        title_error = { fg = "#f38ba8"; };      # red
      };

      filetype = {
        rules = [
          { mime = "image/*"; fg = "#94e2d5"; }   # teal
          { mime = "video/*"; fg = "#f9e2af"; }   # yellow
          { mime = "audio/*"; fg = "#f9e2af"; }   # yellow
          { mime = "application/zip"; fg = "#f5c2e7"; } # pink
          { mime = "application/gzip"; fg = "#f5c2e7"; } # pink
          { mime = "application/x-tar"; fg = "#f5c2e7"; } # pink
          { mime = "application/pdf"; fg = "#f38ba8"; }  # red
          { name = "*.rs"; fg = "#fab387"; }      # peach (rust)
          { name = "*.go"; fg = "#89dceb"; }      # sky (go)
          { name = "*.py"; fg = "#f9e2af"; }      # yellow (python)
          { name = "*.js"; fg = "#f9e2af"; }      # yellow (js)
          { name = "*.ts"; fg = "#89b4fa"; }      # blue (ts)
          { name = "*.nix"; fg = "#89dceb"; }     # sky (nix)
          { name = "*.md"; fg = "#cdd6f4"; }      # text
          { name = "*"; fg = "#cdd6f4"; }         # text (default)
        ];
      };
    };
  };

  # Dependencies for previews
  home.packages = with pkgs; [
    ffmpegthumbnailer  # Video thumbnails
    unar               # Archive preview
    poppler            # PDF preview
    imagemagick        # Image processing
    file               # File type detection
  ];
}
