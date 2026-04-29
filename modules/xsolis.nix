# Xsolis work environment
# Activates only inside ~/xsolis/ via direnv (see ~/xsolis/.envrc).
# All xsolis-specific tooling and config lives here so it can be removed by
# deleting one import line in home/kadza.nix.
{ config, pkgs, lib, ... }: {
  home.packages = with pkgs; [
    dotnet-sdk_8   # .NET 8 SDK (runs .NET 6 projects too)
    granted        # AWS SSO profile UX (assume, console)
    liquibase      # Database schema migrations
  ];
}
