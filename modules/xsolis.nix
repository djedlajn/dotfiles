# Xsolis work environment
# Activates only inside ~/xsolis/ via direnv (see ~/xsolis/.envrc).
# All xsolis-specific tooling and config lives here so it can be removed by
# deleting one import line in home/kadza.nix.
{ config, pkgs, lib, ... }: {
  home.packages = with pkgs; [
    dotnet-sdk_8   # .NET 8 SDK (runs .NET 6 projects too)
    granted        # AWS SSO profile UX (assume, console)
    liquibase      # Database schema migrations

    (writeShellScriptBin "xsolis-nuget-init" ''
      # Scaffold nuget.config in the current dir with xsolis-nuget-store + any
      # extra repo names passed as args.
      # Usage: xsolis-nuget-init [extra-repo-name ...]
      # Example: xsolis-nuget-init xsolis-cortex-core
      set -euo pipefail

      ACCT=370752999763
      REGION=us-east-1
      DOMAIN=xsolis-development

      ${dotnet-sdk_8}/bin/dotnet new nugetconfig --force >/dev/null
      # Remove the default api.nuget.org source — xsolis-nuget-store is the
      # proxy for public packages.
      ${dotnet-sdk_8}/bin/dotnet nuget remove source nuget --configfile ./nuget.config >/dev/null
      ${dotnet-sdk_8}/bin/dotnet nuget add source \
        "https://''${DOMAIN}-''${ACCT}.d.codeartifact.''${REGION}.amazonaws.com/nuget/xsolis-nuget-store/v3/index.json" \
        -n "xsolis-development/xsolis-nuget-store" --configfile ./nuget.config

      for repo in "$@"; do
        ${dotnet-sdk_8}/bin/dotnet nuget add source \
          "https://''${DOMAIN}-''${ACCT}.d.codeartifact.''${REGION}.amazonaws.com/nuget/''${repo}/v3/index.json" \
          -n "xsolis-development/''${repo}" --configfile ./nuget.config
      done

      echo "✓ nuget.config written. Sources: xsolis-nuget-store $*"
    '')
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

  # ── direnv activation under ~/xsolis/ ──
  # Loaded by direnv on `cd ~/xsolis/<anything>`. Sets AWS profile, region,
  # and activates mise (which reads .mise.toml below for Node/dotnet versions).
  home.file."xsolis/.envrc".text = ''
    # shellcheck shell=bash
    export AWS_PROFILE=xsolis-dev
    export AWS_REGION=us-east-1
    export AWS_DEFAULT_REGION=us-east-1

    # Cheap local check — looks for a non-expired SSO token cache file.
    # Avoids a network call to STS on every `cd`.
    if ! find "$HOME/.aws/sso/cache" -name '*.json' -mmin -480 2>/dev/null | grep -q .; then
      echo "→ AWS SSO session likely expired — run: xsl-login"
    fi

    use mise

    [[ -f .envrc.local ]] && source_env .envrc.local
  '';

  # ── mise pinned versions for ~/xsolis/ (Node 20, .NET 8) ──
  # Subprojects can override by committing their own .mise.toml or global.json.
  home.file."xsolis/.mise.toml".text = ''
    [tools]
    node = "20"
    dotnet = "8"
  '';
}
