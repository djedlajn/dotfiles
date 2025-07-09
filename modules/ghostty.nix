# Ghostty terminal emulator configuration
# Package managed via nix-darwin homebrew module
# Docs: https://ghostty.org/docs
{ ... }: {
  # Configuration
  xdg.configFile."ghostty/config".text = ''
    # Font
    font-family = JetBrainsMono Nerd Font Mono
    font-size = 14
    font-thicken = true
    adjust-cell-height = 10%

    # Theme - Catppuccin Mocha
    theme = catppuccin-mocha

    # Window
    window-padding-x = 12
    window-padding-y = 10
    window-decoration = auto
    macos-titlebar-style = tabs
    macos-option-as-alt = true

    # Cursor
    cursor-style = block
    cursor-style-blink = false
    mouse-hide-while-typing = true

    # Clipboard
    clipboard-read = allow
    clipboard-write = allow
    clipboard-paste-protection = false
    copy-on-select = clipboard

    # Scrollback
    scrollback-limit = 100000

    # Quick terminal (Quake-style dropdown with Cmd+`)
    keybind = global:cmd+grave_accent=toggle_quick_terminal
    keybind = cmd+t=new_tab
    keybind = cmd+w=close_surface
    keybind = cmd+shift+enter=new_split:right
    keybind = cmd+shift+minus=new_split:down
    keybind = cmd+opt+left=goto_split:left
    keybind = cmd+opt+right=goto_split:right
    keybind = cmd+opt+up=goto_split:top
    keybind = cmd+opt+down=goto_split:bottom
    keybind = cmd+shift+f=toggle_fullscreen
    keybind = cmd+plus=increase_font_size:1
    keybind = cmd+minus=decrease_font_size:1
    keybind = cmd+zero=reset_font_size
  '';

  # Catppuccin Mocha theme file
  xdg.configFile."ghostty/themes/catppuccin-mocha".text = ''
    background = 1e1e2e
    foreground = cdd6f4
    cursor-color = f5e0dc
    selection-background = 45475a
    selection-foreground = cdd6f4

    # Black
    palette = 0=#45475a
    palette = 8=#585b70
    # Red
    palette = 1=#f38ba8
    palette = 9=#f38ba8
    # Green
    palette = 2=#a6e3a1
    palette = 10=#a6e3a1
    # Yellow
    palette = 3=#f9e2af
    palette = 11=#f9e2af
    # Blue
    palette = 4=#89b4fa
    palette = 12=#89b4fa
    # Magenta
    palette = 5=#f5c2e7
    palette = 13=#f5c2e7
    # Cyan
    palette = 6=#94e2d5
    palette = 14=#94e2d5
    # White
    palette = 7=#bac2de
    palette = 15=#a6adc8
  '';
}
