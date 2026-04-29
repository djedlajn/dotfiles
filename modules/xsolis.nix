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

  # ── AWS SSO config ──
  # Sources: account IDs / start URL from xsolis Okta SSO portal.
  # Credentials live in ~/.aws/credentials (managed by `aws sso login`); this
  # file is config only (start URL, account, role) and is fine to commit.
  home.file.".aws/config".text = ''
    [sso-session xsolis]
    sso_start_url = https://d-906707b7d1.awsapps.com/start
    sso_region = us-east-1
    sso_registration_scopes = sso:account:access

    # ─── Development (default) ───
    [profile xsolis-dev]
    sso_session = xsolis
    sso_account_id = 370752999763
    sso_role_name = PowerUserAccess
    region = us-east-1
    output = json

    [profile xsolis-dev-readonly]
    sso_session = xsolis
    sso_account_id = 370752999763
    sso_role_name = ViewOnlyAccess
    region = us-east-1
    output = json

    [profile xsolis-dev-epam]
    sso_session = xsolis
    sso_account_id = 370752999763
    sso_role_name = EPAMAccess
    region = us-east-1
    output = json

    # ─── Integration ───
    [profile xsolis-int]
    sso_session = xsolis
    sso_account_id = 860278407645
    sso_role_name = PowerUserAccess
    region = us-east-1
    output = json

    [profile xsolis-int-readonly]
    sso_session = xsolis
    sso_account_id = 860278407645
    sso_role_name = ViewOnlyAccess
    region = us-east-1
    output = json
  '';
}
