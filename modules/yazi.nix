{ pkgs, ... }: {
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";

    settings = {
      # yazi 25.2.26 renamed [manager] -> [mgr]; 26.x no longer accepts the old name.
      mgr = {
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
      };

      opener = {
        edit = [
          {
            run = "\${EDITOR:-vim} \"$@\"";
            block = true;
            for = "unix";
          }
        ];
        open = [
          {
            run = "open \"$@\"";
            for = "macos";
          }
        ];
      };
    };

    # Only deviations from yazi's built-in defaults live here: prepend_keymap
    # merges on top of the preset, unlike the old `keymap =` form which replaced
    # the whole [mgr] section (and silently dropped arrow keys, seek, spot,
    # copy-path, linemode and help bindings).
    keymap = {
      mgr.prepend_keymap = [
        {
          on = [ "<C-q>" ];
          run = "close";
          desc = "Close tab";
        }

        # Preset binds K/J to preview seek; fast cursor movement is more useful.
        {
          on = [ "K" ];
          run = "arrow -5";
          desc = "Move up 5";
        }
        {
          on = [ "J" ];
          run = "arrow 5";
          desc = "Move down 5";
        }

        # Preset only offers <S-Enter> for interactive open.
        {
          on = [ "<C-Enter>" ];
          run = "open --interactive";
          desc = "Open interactively";
        }

        # Sorting: unlike the preset `,` keys, these keep the configured "size"
        # linemode (the preset also switches linemode) and force dirs first.
        {
          on = [
            ","
            "m"
          ];
          run = "sort mtime --dir-first";
          desc = "Sort by modified";
        }
        {
          on = [
            ","
            "M"
          ];
          run = "sort mtime --reverse --dir-first";
          desc = "Sort by modified (reverse)";
        }
        {
          on = [
            ","
            "n"
          ];
          run = "sort natural --dir-first";
          desc = "Sort by name";
        }
        {
          on = [
            ","
            "N"
          ];
          run = "sort natural --reverse --dir-first";
          desc = "Sort by name (reverse)";
        }
        {
          on = [
            ","
            "s"
          ];
          run = "sort size --dir-first";
          desc = "Sort by size";
        }
        {
          on = [
            ","
            "S"
          ];
          run = "sort size --reverse --dir-first";
          desc = "Sort by size (reverse)";
        }

        # Single-key new tab (preset uses the `t t` chord; this shadows it).
        {
          on = [ "t" ];
          run = "tab_create --current";
          desc = "New tab";
        }

        # Swapped vs preset: `:` fires a quick command, `;` blocks for output.
        {
          on = [ ":" ];
          run = "shell --interactive";
          desc = "Shell command";
        }
        {
          on = [ ";" ];
          run = "shell --block --interactive";
          desc = "Shell command (block)";
        }

        # Lazygit integration
        {
          on = [ "<C-g>" ];
          run = "shell 'lazygit' --block";
          desc = "Open lazygit";
        }
      ];
    };

    # Catppuccin Mocha via the official yazi flavor.
    # NOTE: yazi 25.2.26 renamed theme.toml sections ([manager]->[mgr],
    # [select]->[pick], filetype `name`->`url`, ...); the old hand-rolled
    # theme was rejected by yazi >= 26.x with a blocking prompt at launch.
    flavors.catppuccin-mocha =
      pkgs.fetchFromGitHub {
        owner = "yazi-rs";
        repo = "flavors";
        rev = "4770a3467169bfdb0a3b11601921aaf27c100630";
        hash = "sha256-erZI0H5TxqFu2P917juL5PIB3LC0oJGKPcB1VibJDqo=";
      }
      + "/catppuccin-mocha.yazi";

    theme.flavor.dark = "catppuccin-mocha";
  };
}
