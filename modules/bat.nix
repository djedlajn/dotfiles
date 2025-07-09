{ pkgs, ... }: {
  programs.bat = {
    enable = true;
    config = {
      theme = "catppuccin-mocha";
      italic-text = "always";
      style = "numbers,changes,header,grid";
      pager = "less -FR";
      map-syntax = [
        "*.jenkinsfile:Groovy"
        "*.props:Java Properties"
        ".ignore:Git Ignore"
        "*.nix:Nix"
      ];
    };

    extraPackages = with pkgs.bat-extras; [
      batdiff    # Diff with syntax highlighting
      batman     # Man pages with syntax highlighting
      batgrep    # Ripgrep with bat previews
      batwatch   # Watch files with syntax highlighting
    ];

    # Catppuccin Mocha theme
    # Structure: themes.<name> = { src = <path>; file = <optional subpath>; }
    themes = {
      catppuccin-mocha = {
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "bat";
          rev = "699f60fc8ec434574ca7451b444b880430319941";
          hash = "sha256-6fWoCH90IGumAMc4buLRWL0N61op+AuMNN9CAR9/OdI=";
        };
        file = "themes/Catppuccin Mocha.tmTheme";
      };
    };
  };

  # Set BAT_THEME for other tools that use bat
  home.sessionVariables = {
    BAT_THEME = "catppuccin-mocha";
  };
}
