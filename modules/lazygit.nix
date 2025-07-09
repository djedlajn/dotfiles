# Lazygit configuration
# Docs: https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md
{ ... }: {
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        # Nerd Fonts v3 for icons (replaces deprecated showIcons)
        nerdFontsVersion = "3";
        showRandomTip = false;
        border = "rounded";

        # Time display formats
        language = "auto";
        timeFormat = "02 Jan 06";
        shortTimeFormat = "3:04PM";

        # Catppuccin Mocha theme
        theme = {
          activeBorderColor = [ "#cba6f7" "bold" ];       # mauve
          inactiveBorderColor = [ "#a6adc8" ];            # subtext0
          searchingActiveBorderColor = [ "#f9e2af" "bold" ]; # yellow
          optionsTextColor = [ "#89b4fa" ];               # blue
          selectedLineBgColor = [ "#313244" ];            # surface0
          inactiveViewSelectedLineBgColor = [ "#45475a" ]; # surface1
          cherryPickedCommitFgColor = [ "#f38ba8" ];      # red
          cherryPickedCommitBgColor = [ "#45475a" ];      # surface1
          markedBaseCommitFgColor = [ "#f9e2af" ];        # yellow
          markedBaseCommitBgColor = [ "#313244" ];        # surface0
          unstagedChangesColor = [ "#f38ba8" ];           # red
          defaultFgColor = [ "#cdd6f4" ];                 # text
        };
      };

      git = {
        paging = {
          colorArg = "always";
          # Delta with line numbers and clickable file links
          pager = "delta --dark --paging=never --line-numbers --hyperlinks --hyperlinks-file-link-format=\"lazygit-edit://{path}:{line}\"";
        };
        autoFetch = true;
        autoRefresh = true;
        parseEmoji = true;
      };

      os = {
        editPreset = "vim";
      };

      confirmOnQuit = false;

      customCommands = [
        # Open in browser (PR or repo)
        {
          key = "<c-o>";
          context = "global";
          command = "gh pr view --web || gh browse";
          description = "Open in browser";
        }
        # Browse commit on GitHub
        {
          key = "<c-b>";
          context = "commits";
          command = "gh browse -- \"commit/{{.SelectedLocalCommit.Hash}}\"";
          description = "Browse commit on GitHub";
        }
        # Create PR
        {
          key = "O";
          context = "localBranches";
          command = "gh pr create --web";
          description = "Create PR on GitHub";
        }
        # Fetch all remotes
        {
          key = "F";
          context = "global";
          command = "git fetch --all --prune";
          description = "Fetch all remotes";
        }
      ];
    };
  };
}
