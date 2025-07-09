{ ... }: {
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [
      "--cmd cd"  # Replace cd command entirely
    ];
  };
}
