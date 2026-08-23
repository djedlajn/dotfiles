# Fastfetch system-info splash.
# Shared verbatim between ~/.config/nix/modules and cc-remote nixos/home/.
# Logo auto-detects per OS (Apple on the Mac, NixOS snowflake on the box).
{ ... }: {
  programs.fastfetch = {
    enable = true;

    settings = {
      logo = {
        padding = {
          top = 1;
          right = 4;
        };
      };

      display = {
        separator = "  ";
        # Catppuccin Mocha mauve for keys via the closest ANSI color
        color = {
          keys = "magenta";
          title = "magenta";
        };
      };

      modules = [
        "title"
        "separator"
        "os"
        "host"
        "kernel"
        "uptime"
        "packages"
        "shell"
        "terminal"
        "cpu"
        "memory"
        "disk"
        "localip"
        "break"
        "colors"
      ];
    };
  };
}
