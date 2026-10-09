{ ... }:
{
  programs.zellij = {
    enable = true;

    # Zellij is launched on demand (`zj` alias), never auto-started per shell
    enableZshIntegration = false;

    # Stock keybinds — a previous keybinds block here reproduced zellij's
    # defaults verbatim (merge was a no-op). Add custom binds deliberately,
    # with clear-defaults considered, if ever needed.
    settings = {
      theme = "catppuccin-mocha";

      themes.catppuccin-mocha = {
        bg = "#1e1e2e"; # base
        fg = "#cdd6f4"; # text
        red = "#f38ba8";
        green = "#a6e3a1";
        yellow = "#f9e2af";
        blue = "#89b4fa";
        magenta = "#cba6f7"; # mauve
        cyan = "#94e2d5"; # teal
        orange = "#fab387"; # peach
        black = "#181825"; # mantle
        white = "#cdd6f4"; # text
      };
    };
  };
}
