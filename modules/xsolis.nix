# Xsolis work environment
# Activates only inside ~/xsolis/ via direnv (see ~/xsolis/.envrc).
# All xsolis-specific tooling and config lives here so it can be removed by
# deleting one import line in home/kadza.nix.
{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    dotnet-sdk_8   # .NET 8 SDK (runs .NET 6 projects too)
    granted        # AWS SSO profile UX (assume, console)
    liquibase      # Database schema migrations
    gnupg          # GPG for xsolis commit signing (key: ukaric@xsolis.com)
    pinentry_mac   # macOS GUI passphrase prompt (used by gpg-agent if a passphrase is added later)

    (writeShellScriptBin "xsolis-nuget-init" ''
      # Scaffold nuget.config in the current dir with the standard xsolis
      # CodeArtifact sources, plus any extra repo names passed as args.
      #
      # Defaults (always included):
      #   - xsolis-nuget-store: proxy for public packages (replaces api.nuget.org)
      #   - xsolis-cortex-core: all internal Xsolis.* packages, including the
      #     Xsolis.*.Avro family and Xsolis.Cortex.Core.*
      #
      # Usage: xsolis-nuget-init [extra-repo-name ...]
      # Example: xsolis-nuget-init xsolis-component-library
      set -euo pipefail

      ACCT=370752999763
      REGION=us-east-1
      DOMAIN=xsolis-development
      DEFAULT_REPOS=(xsolis-nuget-store xsolis-cortex-core)

      ${dotnet-sdk_8}/bin/dotnet new nugetconfig --force >/dev/null
      # Remove the default api.nuget.org source — xsolis-nuget-store is the
      # proxy for public packages.
      ${dotnet-sdk_8}/bin/dotnet nuget remove source nuget --configfile ./nuget.config >/dev/null

      for repo in "''${DEFAULT_REPOS[@]}" "$@"; do
        ${dotnet-sdk_8}/bin/dotnet nuget add source \
          "https://''${DOMAIN}-''${ACCT}.d.codeartifact.''${REGION}.amazonaws.com/nuget/''${repo}/v3/index.json" \
          -n "xsolis-development/''${repo}" --configfile ./nuget.config
      done

      echo "✓ nuget.config written. Sources: ''${DEFAULT_REPOS[*]} $*"
    '')

    (writeShellScriptBin "xsolis-dotnet-login" ''
      # Configure dotnet/NuGet to use the xsolis AWS CodeArtifact registries.
      # Writes registry URLs + 12h auth tokens into ~/.nuget/NuGet/NuGet.Config
      # (user-level — project nuget.config stays clean, no secrets to gitignore).
      # Requires a valid AWS SSO session (run xsl-login first).
      #
      # Logs into both standard repos:
      #   - xsolis-nuget-store (public NuGet proxy)
      #   - xsolis-cortex-core (internal Xsolis.* packages, incl. all *.Avro)
      #
      # Why this and not AWS.CodeArtifact.NuGet.CredentialProvider:
      # the credential provider installs fine but NuGet's plugin protocol
      # silently fails to obtain creds (NU1301 with no useful logs). The
      # `--tool dotnet` login is AWS-documented Method 1 and just works.
      set -euo pipefail

      ACCT=370752999763
      REGION=us-east-1
      DOMAIN=xsolis-development
      PROFILE="''${AWS_PROFILE:-xsolis-dev}"

      for repo in xsolis-nuget-store xsolis-cortex-core "$@"; do
        ${awscli2}/bin/aws codeartifact login --tool dotnet \
          --profile "$PROFILE" \
          --domain "$DOMAIN" \
          --domain-owner "$ACCT" \
          --region "$REGION" \
          --repository "$repo"
      done
    '')

    (writeShellScriptBin "xsolis-npm-login" ''
      # Configure npm to use the xsolis AWS CodeArtifact registry. Writes the
      # registry URL + 12h auth token into ~/xsolis/.npmrc (NOT the global
      # ~/.npmrc), so xsolis registries apply only under ~/xsolis/ — see the
      # NPM_CONFIG_USERCONFIG export in ~/xsolis/.envrc.
      # Requires a valid AWS SSO session (run xsl-login first).
      # Default repo is xsolis-component-library because it has npm-store
      # (the public-npm proxy) as an upstream — one login covers both
      # internal and public packages.
      # Usage: xsolis-npm-login [repository]
      set -euo pipefail

      ACCT=370752999763
      REGION=us-east-1
      DOMAIN=xsolis-development
      REPO="''${1:-xsolis-component-library}"
      # Default profile if direnv didn't export it (e.g. running outside ~/xsolis/).
      PROFILE="''${AWS_PROFILE:-xsolis-dev}"

      # Pin npm's user config to ~/xsolis/.npmrc so the token lands there even
      # when this is run manually from outside ~/xsolis/ (where .envrc hasn't
      # exported NPM_CONFIG_USERCONFIG). Keeps the global ~/.npmrc untouched.
      export NPM_CONFIG_USERCONFIG="$HOME/xsolis/.npmrc"
      mkdir -p "$HOME/xsolis"

      ${awscli2}/bin/aws codeartifact login --tool npm \
        --profile "$PROFILE" \
        --domain "$DOMAIN" \
        --domain-owner "$ACCT" \
        --region "$REGION" \
        --repository "$REPO"
    '')
  ];

  # ── granted (assume) shell wrapper ──
  # `assume` must be sourced (not executed) so it can export AWS_PROFILE +
  # session creds into the current shell. zsh's `source` resolves bare names
  # via $PATH, so this finds the script shipped by the granted package.
  programs.zsh.shellAliases.assume = "source assume";

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

    # Scope npm's user config to ~/xsolis/ so the CodeArtifact registry + token
    # apply only here; the global ~/.npmrc stays on public npm. direnv inherits
    # this into every subdir of ~/xsolis/.
    export NPM_CONFIG_USERCONFIG="$HOME/xsolis/.npmrc"

    # Cheap local check — looks for a non-expired SSO token cache file.
    # Avoids a network call to STS on every `cd`.
    if ! find "$HOME/.aws/sso/cache" -name '*.json' -mmin -480 2>/dev/null | grep -q .; then
      echo "→ AWS SSO session likely expired — run: xsl-login (then xsolis-npm-login + xsolis-dotnet-login)"
    else
      # CodeArtifact npm token lasts 12h. Refresh when ~/xsolis/.npmrc is missing
      # the codeartifact registry line, or older than 11h (660 min).
      if [[ ! -f "$NPM_CONFIG_USERCONFIG" ]] \
         || ! grep -q "xsolis-development-370752999763.d.codeartifact" "$NPM_CONFIG_USERCONFIG" \
         || [[ -n $(find "$NPM_CONFIG_USERCONFIG" -mmin +660 -print 2>/dev/null) ]]; then
        echo "→ npm CodeArtifact token stale — refreshing..."
        xsolis-npm-login || echo "  (failed; run xsolis-npm-login manually)"
      fi

      # Same dance for dotnet: tokens go into ~/.nuget/NuGet/NuGet.Config.
      NUGET_CONFIG="$HOME/.nuget/NuGet/NuGet.Config"
      if [[ ! -f "$NUGET_CONFIG" ]] \
         || ! grep -q "xsolis-development-370752999763.d.codeartifact" "$NUGET_CONFIG" \
         || [[ -n $(find "$NUGET_CONFIG" -mmin +660 -print 2>/dev/null) ]]; then
        echo "→ dotnet CodeArtifact token stale — refreshing..."
        xsolis-dotnet-login || echo "  (failed; run xsolis-dotnet-login manually)"
      fi
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

  # ── GPG agent config (xsolis key) ──
  # Wires gpg-agent to use macOS-native passphrase GUI. Harmless when the
  # current key has no passphrase (gpg-agent only invokes pinentry on demand).
  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program ${pkgs.pinentry_mac}/bin/pinentry-mac
    default-cache-ttl 3600
    max-cache-ttl 86400
  '';

  # NOTE: previously this module installed AWS.CodeArtifact.NuGet.CredentialProvider
  # as a dotnet global tool + NuGet plugin. The plugin installs cleanly and
  # NuGet picks it up, but it silently fails to return creds (NU1301 with no
  # plugin logs). We use `aws codeartifact login --tool dotnet` instead — see
  # xsolis-dotnet-login above. Clean up the now-unused tool with:
  #   dotnet tool uninstall -g AWS.CodeArtifact.NuGet.CredentialProvider
  #   rm -rf ~/.nuget/plugins/netcore/AWS.CodeArtifact.NuGetCredentialProvider
}
