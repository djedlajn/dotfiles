{ config, ... }: {
  home.file.".config/zellij/config.kdl".text = ''
    // Catppuccin Mocha theme
    theme "catppuccin-mocha"

    keybinds {
        normal {
            bind "Ctrl g" { SwitchToMode "locked"; }
            bind "Ctrl p" { SwitchToMode "pane"; }
            bind "Alt n" { NewPane; }
            bind "Alt h" "Alt Left" { MoveFocusOrTab "Left"; }
        }
        pane {
            bind "h" "Left" { MoveFocus "Left"; }
            bind "l" "Right" { MoveFocus "Right"; }
            bind "j" "Down" { MoveFocus "Down"; }
            bind "k" "Up" { MoveFocus "Up"; }
            bind "p" { SwitchFocus; }
        }
        locked {
            bind "Ctrl g" { SwitchToMode "normal"; }
        }
    }

    // Catppuccin Mocha palette
    themes {
        catppuccin-mocha {
            bg "#1e1e2e"        // base
            fg "#cdd6f4"        // text
            red "#f38ba8"
            green "#a6e3a1"
            yellow "#f9e2af"
            blue "#89b4fa"
            magenta "#cba6f7"   // mauve
            cyan "#94e2d5"      // teal
            orange "#fab387"    // peach
            black "#181825"     // mantle
            white "#cdd6f4"     // text
        }
    }
  '';
} 