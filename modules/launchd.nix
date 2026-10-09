# live.uros.dev uploaders — the scripts live in the live-worker repo (synced via
# ~/sync) and stay hand-edited; only the schedule and environment are declared.
#
# launchd's default PATH is /usr/bin:/bin:/usr/sbin:/sbin, where python3 and git
# are Xcode shims that fail whenever the Xcode license needs re-accepting (after
# every Xcode update). Nix builds come first; /usr/bin:/bin follow so the
# scripts keep BSD find/awk/mktemp/date, which differ from GNU's.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  home = config.home.homeDirectory;
  scripts = "${home}/sync/live-worker/scripts";

  path =
    lib.makeBinPath [
      pkgs.python3
      pkgs.curl
      config.programs.git.package
    ]
    + ":/usr/bin:/bin";

  # Label and log file keep the names of the original hand-installed agents,
  # so the first switch replaces those plists in place.
  uploader = name: {
    enable = true;
    config = {
      Label = "dev.uros.${name}";
      # -f skips nix-darwin's /etc/zshenv set-environment and HM's ~/.zshenv,
      # which would otherwise replace PATH with the interactive one.
      ProgramArguments = [
        "/bin/zsh"
        "-f"
        "${scripts}/${name}.sh"
      ];
      StartInterval = 600;
      RunAtLoad = true;
      StandardOutPath = "${home}/Library/Logs/dev.uros.${name}.log";
      StandardErrorPath = "${home}/Library/Logs/dev.uros.${name}.log";
      EnvironmentVariables.PATH = path;
    };
  };
in
{
  launchd.agents = {
    commit-stats = uploader "commit-stats";
    pi-tokens = uploader "pi-tokens";
  };
}
