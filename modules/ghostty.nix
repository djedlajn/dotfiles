# Ghostty terminal emulator configuration
# App: Homebrew cask ghostty@tip (nightly). Brew owns the bundle so Sparkle can
# update it in place; nix only writes the config.
# Docs: https://ghostty.org/docs
{
  programs.ghostty = {
    enable = true;
    package = null;

    settings = {
      font-family = "JetBrainsMono Nerd Font Mono";
      font-size = 14;
      font-thicken = true;
      adjust-cell-height = "10%";

      theme = "catppuccin-mocha";

      window-padding-x = 12;
      window-padding-y = 10;
      window-decoration = "auto";
      macos-titlebar-style = "tabs";
      macos-option-as-alt = true;

      cursor-style = "block";
      cursor-style-blink = false;
      mouse-hide-while-typing = true;

      clipboard-read = "allow";
      clipboard-write = "allow";
      clipboard-paste-protection = false;
      copy-on-select = "clipboard";

      scrollback-limit = 100000;

      keybind = [
        # Quick terminal (Quake-style dropdown with Cmd+`)
        "global:cmd+grave_accent=toggle_quick_terminal"
        "cmd+t=new_tab"
        "cmd+w=close_surface"
        "cmd+shift+enter=new_split:right"
        "cmd+shift+minus=new_split:down"
        "cmd+opt+left=goto_split:left"
        "cmd+opt+right=goto_split:right"
        "cmd+opt+up=goto_split:top"
        "cmd+opt+down=goto_split:bottom"
        "cmd+shift+f=toggle_fullscreen"
        "cmd+plus=increase_font_size:1"
        "cmd+minus=decrease_font_size:1"
        "cmd+zero=reset_font_size"
      ];
    };

    themes.catppuccin-mocha = {
      background = "1e1e2e";
      foreground = "cdd6f4";
      cursor-color = "f5e0dc";
      selection-background = "45475a";
      selection-foreground = "cdd6f4";
      palette = [
        "0=#45475a"
        "1=#f38ba8"
        "2=#a6e3a1"
        "3=#f9e2af"
        "4=#89b4fa"
        "5=#f5c2e7"
        "6=#94e2d5"
        "7=#bac2de"
        "8=#585b70"
        "9=#f38ba8"
        "10=#a6e3a1"
        "11=#f9e2af"
        "12=#89b4fa"
        "13=#f5c2e7"
        "14=#94e2d5"
        "15=#a6adc8"
      ];
    };
  };
}
