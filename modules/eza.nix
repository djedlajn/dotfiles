{ ... }: {
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    git = true;
    icons = "auto";
    extraOptions = [
      "--group-directories-first"
      "--header"
      "--hyperlink"
      "--color-scale"
      "--time-style=relative"
      "--no-user"
    ];
  };
}
