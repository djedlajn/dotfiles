# Xsolis Work Environment — Design

**Date:** 2026-04-29
**Status:** Approved (brainstorming phase)

## Goal

Set up a dedicated, directory-scoped development environment for xsolis work
under `~/xsolis/`, covering Git identity, language runtimes (Node 20, .NET 8),
AWS SSO, and NuGet/CodeArtifact integration — without polluting the user's
default environment used for personal projects.

## Constraints

- Must not change behavior outside `~/xsolis/`.
- Must be reproducible: a fresh machine running `nix switch` reaches a working
  state with only `aws sso login` left to do interactively.
- No xsolis credentials committed to the repo. SSO start URL, account IDs,
  role names, and CodeArtifact source URLs are config (not secrets) and may
  be committed.
- Must coexist with the user's existing Node 24 default and other tooling.

## Activation Model

Per-directory activation via `direnv` + `mise`. Tooling is *installed* by nix
but only *enabled* on the shell PATH and env when the user `cd`s into
`~/xsolis/`.

```
$ cd ~/xsolis/cortex
direnv: loading ~/xsolis/.envrc
direnv: export +AWS_PROFILE +AWS_REGION ...
$ node --version  # → v20.x
$ aws sts get-caller-identity  # → on xsolis-dev profile
$ cd ~
direnv: unloading
$ node --version  # → v24.x (default restored)
```

Already-existing conditional Git identity (`gitdir:~/xsolis/` →
`ukaric@xsolis.com`) in `modules/git.nix:93-103` follows the same pattern;
this design extends it to runtimes, AWS, and NuGet.

## Architecture

### New module: `modules/xsolis.nix`

Owns everything xsolis-specific so the entire integration can be disabled by
removing one import line.

**Responsibilities:**

1. Add packages: `dotnet-sdk_8`, `granted`.
   (`awscli2`, `mise`, `direnv` already exist in `home/kadza.nix` and
   `modules/direnv.nix`.)
2. Write declarative config files via `home.file`:
   - `~/.aws/config`
   - `~/xsolis/.envrc`
   - `~/xsolis/.mise.toml`
3. Install the AWS CodeArtifact NuGet credential provider via a
   `home.activation` hook (idempotent).
4. Install a helper script `xsolis-nuget-init` on PATH for scaffolding
   `nuget.config` files in new projects. Packaged via
   `pkgs.writeShellScriptBin` and added to `home.packages` — this puts it
   on PATH automatically with no manual `chmod` or symlinks.

### Edits to existing files

- `home/kadza.nix` — add `../modules/xsolis.nix` to `imports`.
- `modules/direnv.nix` — add `~/xsolis` to `programs.direnv.config.whitelist.prefix`.
- `modules/shell.nix` —
  - Prepend `$HOME/.dotnet/tools` to `programs.zsh.sessionVariables.PATH`
    so the CodeArtifact credential provider is discoverable.
  - Add two aliases: `xsl-login`, `xsl-whoami`.

### What stays out

- Per-project `.envrc` overrides: live in individual repos, not nix.
- Per-project `nuget.config`: committed per repo.
- `~/.aws/credentials`: managed by `aws sso login` at runtime, not nix.

## File Contents

### `~/.aws/config`

```ini
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
```

### `~/xsolis/.envrc`

```sh
# Activate xsolis tooling for everything under ~/xsolis/

export AWS_PROFILE=xsolis-dev
export AWS_REGION=us-east-1
export AWS_DEFAULT_REGION=us-east-1

# Cheap local check — looks for a non-expired SSO token cache file.
# (Avoids a network call to STS on every `cd`.)
if ! find "$HOME/.aws/sso/cache" -name '*.json' -mmin -480 2>/dev/null | grep -q .; then
  echo "→ AWS SSO session likely expired — run: xsl-login"
fi

use mise

[[ -f .envrc.local ]] && source_env .envrc.local
```

The 480-minute (8-hour) heuristic matches the default SSO session TTL. False
positives just nudge the user to re-login; cost of a wrong nudge is one
keystroke, cost of a real network call on every `cd` is ~300ms.

### `~/xsolis/.mise.toml`

```toml
[tools]
node = "20"
dotnet = "8"
```

A project that needs different versions overrides via its own `.mise.toml`
or `global.json` (mise reads both).

### `bin/xsolis-nuget-init`

```sh
#!/usr/bin/env bash
# Usage: xsolis-nuget-init [extra-repo-name ...]
# Scaffolds nuget.config in the current dir with xsolis-nuget-store + extras.
set -euo pipefail

ACCT=370752999763
REGION=us-east-1
DOMAIN=xsolis-development

dotnet new nugetconfig --force >/dev/null
dotnet nuget add source \
  "https://${DOMAIN}-${ACCT}.d.codeartifact.${REGION}.amazonaws.com/nuget/xsolis-nuget-store/v3/index.json" \
  -n "xsolis-development/xsolis-nuget-store" --configfile ./nuget.config

for repo in "$@"; do
  dotnet nuget add source \
    "https://${DOMAIN}-${ACCT}.d.codeartifact.${REGION}.amazonaws.com/nuget/${repo}/v3/index.json" \
    -n "xsolis-development/${repo}" --configfile ./nuget.config
done

echo "✓ nuget.config written. Sources: xsolis-nuget-store $*"
```

### Activation hook (in `modules/xsolis.nix`)

```nix
home.activation.aws-codeartifact-nuget = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  run --quiet ${pkgs.dotnet-sdk_8}/bin/dotnet tool update -g AWS.CodeArtifact.NuGet.CredentialProvider \
    || run --quiet ${pkgs.dotnet-sdk_8}/bin/dotnet tool install -g AWS.CodeArtifact.NuGet.CredentialProvider
'';
```

## Day-to-day Usage

| Action | Command |
|---|---|
| First-time SSO auth (or after expiry) | `aws sso login --sso-session xsolis` (alias: `xsl-login`) |
| Confirm current identity | `aws sts get-caller-identity` (alias: `xsl-whoami`) |
| Switch to Integration account temporarily | `assume xsolis-int` (Granted) |
| Open AWS console as a role | `assume -c xsolis-dev` (Granted) |
| Scaffold `nuget.config` for a new project | `xsolis-nuget-init xsolis-cortex-core` |

## Bootstrap Sequence (Fresh Machine)

1. `nix run .#switch` (or `nrs` alias) — installs packages, writes config files, runs activation hook.
2. `aws sso login --sso-session xsolis` — opens browser for first-time auth.
3. `cd ~/xsolis/<repo>` — direnv auto-loads, mise installs Node 20 / dotnet 8 if not yet installed.
4. For new dotnet projects: `xsolis-nuget-init <repo-name>`.

## Tradeoffs and Non-Goals

- **No global NuGet config.** Avoids leaking xsolis sources into personal dotnet projects. The cost is one `xsolis-nuget-init` call per new project.
- **Single dotnet SDK version (8).** SDK 8 runs .NET 6 projects. If a project pins SDK 6 via `global.json`, mise will pull it on demand. Adding `dotnet-sdk_6` to nix is a future option (~500 MB cost).
- **`.envrc` does not auto-trigger `aws sso login`.** A `cd` should not open a browser tab. The script prints a message; the user runs `xsl-login` themselves.
- **No declarative `~/.granted/config`.** Granted's defaults are fine. Adding custom config (e.g., browser preference) is a future option.

## Out of Scope

- VPN setup, IDE config (Rider, VSCode), Docker, K8s contexts.
- Production-account profiles (none mentioned by user).
- Migration of any existing local `~/.aws/config` content (will be overwritten — user should back up first if anything custom is there).
