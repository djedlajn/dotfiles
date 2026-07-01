{ config, lib, ... }: {
  programs.zoxide = {
    enable = true;
    # Don't let home-manager inject the init early (it lands near the top of
    # .zshrc). zoxide must initialize LAST — see below.
    enableZshIntegration = false;
  };

  # zoxide registers hooks in both precmd_functions and chpwd_functions. When it
  # inits before oh-my-zsh/starship/atuin, one of them reassigns
  # `precmd_functions=(...)` and drops __zoxide_hook, which trips zoxide's
  # _ZO_DOCTOR warning on every shell ("initialize zoxide at the end..."). Adding
  # the init with mkAfter (order 1500) places it past HM's defaults (oh-my-zsh
  # 800, initContent 1000, syntax-highlighting 1200) so its hooks survive.
  programs.zsh.initContent = lib.mkAfter ''
    eval "$(${config.programs.zoxide.package}/bin/zoxide init zsh --cmd cd)"
  '';
}
