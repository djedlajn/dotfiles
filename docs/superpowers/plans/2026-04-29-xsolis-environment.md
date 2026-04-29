# Xsolis Environment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a directory-scoped xsolis development environment that activates Node 20, .NET 8, AWS SSO profiles, and NuGet/CodeArtifact integration only when working under `~/xsolis/`, leaving the user's default environment unchanged elsewhere.

**Architecture:** A single new home-manager module `modules/xsolis.nix` owns all xsolis-specific config: packages (`dotnet-sdk_8`, `granted`, `liquibase`), declarative `~/.aws/config`, a directory-scoped `.envrc` + `.mise.toml` under `~/xsolis/`, an activation hook that installs the AWS CodeArtifact NuGet credential provider as a dotnet global tool, and a `xsolis-nuget-init` helper script. Existing `direnv.nix` and `shell.nix` modules get small additions (whitelist, PATH, aliases). The whole feature is removed by deleting one import line.

**Tech Stack:** nix-darwin, home-manager, direnv, mise, AWS CLI v2, Granted, .NET 8 SDK, Liquibase.

**Spec:** `docs/superpowers/specs/2026-04-29-xsolis-environment-design.md`

---

## Verification Model

Nix-darwin doesn't have unit tests for config — verification is "does the rebuild succeed" + "does the resulting state look right". The user has these aliases (defined in `modules/shell.nix:151-153`):

- `nrb` → `nh darwin build ~/.config/nix` (build only, no switch — fast feedback)
- `nrs` → `nh darwin switch ~/.config/nix` (build + activate)
- `nfc` → `nix flake check ~/.config/nix` (eval check)

Pattern per task: edit → `nrb` → if green, `nrs` → inspect resulting state.

**One-time prerequisite (not a task):** make sure `~/xsolis/` exists. The user said they want this scoped to `~/xsolis/`, so the module assumes it. If the directory doesn't exist yet, run `mkdir -p ~/xsolis` once.

---

## Task 1: Create `modules/xsolis.nix` with packages only and wire it up

**Goal:** Add the new module with just `dotnet-sdk_8`, `granted`, and `liquibase`. Verify the rebuild succeeds and the binaries are on PATH.

**Files:**
- Create: `modules/xsolis.nix`
- Modify: `home/kadza.nix:21` (add to imports list)

- [ ] **Step 1: Create the bare module**

Write `modules/xsolis.nix`:

```nix
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
```

- [ ] **Step 2: Wire it up in `home/kadza.nix`**

Add the import. Find the existing imports block (currently ends at line 33) and add `../modules/xsolis.nix` to the list. The file currently has Git imports around line 22-23; add the new module after them as a clearly-marked work block:

```nix
    # Git
    ../modules/git.nix
    ../modules/lazygit.nix

    # Work
    ../modules/xsolis.nix

    # Security & SSH
```

- [ ] **Step 3: Build to verify the module evaluates**

Run: `nrb`
Expected: build succeeds, no errors. The diff at the bottom should show `+ dotnet-sdk-8.x.x`, `+ granted-x.x`, `+ liquibase-5.0.2` being added.

- [ ] **Step 4: Activate**

Run: `nrs`
Expected: switch succeeds.

- [ ] **Step 5: Verify binaries on PATH**

Run each in a new shell (or `exec zsh` first):
```bash
which dotnet      # → /etc/profiles/per-user/kadza/bin/dotnet
which granted     # → /etc/profiles/per-user/kadza/bin/granted
which assume      # → /etc/profiles/per-user/kadza/bin/assume (granted ships this too)
which liquibase   # → /etc/profiles/per-user/kadza/bin/liquibase
dotnet --version  # → 8.x.x
liquibase --version  # → Liquibase 5.0.2 (or similar)
```

Expected: all commands resolve and report versions.

- [ ] **Step 6: Commit**

```bash
git add modules/xsolis.nix home/kadza.nix
git commit -m "feat(xsolis): add module with dotnet, granted, liquibase"
```

---

## Task 2: Declarative `~/.aws/config`

**Goal:** Write a managed `~/.aws/config` with the SSO session and all six profiles. Verify the file exists and `aws configure list-profiles` reports them.

**Files:**
- Modify: `modules/xsolis.nix` (add `home.file."\.aws/config"` block)

- [ ] **Step 1: Add the AWS config to the module**

In `modules/xsolis.nix`, after the `home.packages` list and before the closing `}`, add:

```nix
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
```

- [ ] **Step 2: Pre-flight — back up any existing `~/.aws/config`**

Home-manager will refuse to clobber existing untracked files. If the user has one, it will be moved aside with `.backup` suffix automatically (per `flake.nix:57` setting `backupFileExtension = "backup"`), but better to know:

```bash
[[ -f ~/.aws/config ]] && cp ~/.aws/config ~/.aws/config.preflight-backup-$(date +%Y%m%d) && echo "saved a manual backup" || echo "no existing config, fresh install"
```

Expected: either confirms a backup is saved, or reports no existing config.

- [ ] **Step 3: Build**

Run: `nrb`
Expected: success.

- [ ] **Step 4: Activate**

Run: `nrs`
Expected: success. If a previous file existed, `~/.aws/config.backup` will appear.

- [ ] **Step 5: Verify the file content and that AWS CLI sees the profiles**

```bash
cat ~/.aws/config
aws configure list-profiles
```

Expected: file shows the SSO session block and six profiles. `list-profiles` prints:
```
xsolis-dev
xsolis-dev-readonly
xsolis-dev-epam
xsolis-int
xsolis-int-readonly
```

- [ ] **Step 6: Smoke-test SSO login (optional but recommended)**

```bash
aws sso login --sso-session xsolis
```

Expected: opens browser, completes login, prints "Successfully logged into Start URL".
Then:
```bash
aws sts get-caller-identity --profile xsolis-dev
```
Expected: returns the user's identity in account `370752999763`.

- [ ] **Step 7: Commit**

```bash
git add modules/xsolis.nix
git commit -m "feat(xsolis): declarative ~/.aws/config with SSO session"
```

---

## Task 3: Direnv whitelist for `~/xsolis`

**Goal:** Make direnv auto-load `.envrc` files anywhere under `~/xsolis/` without requiring manual `direnv allow`. This must be in place before Task 4 drops the `.envrc` file.

**Files:**
- Modify: `modules/direnv.nix:14-16` (extend the `whitelist.prefix` list)

- [ ] **Step 1: Extend the whitelist**

Open `modules/direnv.nix`. The current block at lines 14-16 reads:

```nix
      whitelist = {
        prefix = [
          "~/projects"
          "~/code"
        ];
      };
```

Change it to:

```nix
      whitelist = {
        prefix = [
          "~/projects"
          "~/code"
          "~/xsolis"
        ];
      };
```

- [ ] **Step 2: Build**

Run: `nrb`
Expected: success.

- [ ] **Step 3: Activate**

Run: `nrs`
Expected: success.

- [ ] **Step 4: Verify the new whitelist value**

Direnv reads its config from `~/.config/direnv/direnv.toml`. Inspect it:
```bash
cat ~/.config/direnv/direnv.toml
```
Expected: the `[whitelist]` section's `prefix = ...` array now contains `"~/xsolis"`.

- [ ] **Step 5: Commit**

```bash
git add modules/direnv.nix
git commit -m "feat(direnv): whitelist ~/xsolis for auto-loading"
```

---

## Task 4: `~/xsolis/.envrc` and `~/xsolis/.mise.toml`

**Goal:** Drop the directory-scoped `.envrc` and `.mise.toml` so that `cd ~/xsolis/<anywhere>` activates Node 20, .NET 8, and the `xsolis-dev` AWS profile.

**Files:**
- Modify: `modules/xsolis.nix` (add two `home.file` blocks)

**Note:** `home.file` writes paths relative to `$HOME`, so the keys are `"xsolis/.envrc"` and `"xsolis/.mise.toml"`. Home-manager will create `~/xsolis/` if missing.

- [ ] **Step 1: Add the `.envrc`**

In `modules/xsolis.nix`, append (still inside the same attribute set):

```nix
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
```

- [ ] **Step 2: Add the `.mise.toml`**

In `modules/xsolis.nix`, append:

```nix
  # ── mise pinned versions for ~/xsolis/ (Node 20, .NET 8) ──
  # Subprojects can override by committing their own .mise.toml or global.json.
  home.file."xsolis/.mise.toml".text = ''
    [tools]
    node = "20"
    dotnet = "8"
  '';
```

- [ ] **Step 3: Build**

Run: `nrb`
Expected: success.

- [ ] **Step 4: Activate**

Run: `nrs`
Expected: success. If `~/xsolis/.envrc` or `~/xsolis/.mise.toml` exist as untracked files, they'll be moved to `.backup`.

- [ ] **Step 5: Verify files were written**

```bash
cat ~/xsolis/.envrc
cat ~/xsolis/.mise.toml
```
Expected: both files contain the expected content.

- [ ] **Step 6: Verify direnv activates**

```bash
mkdir -p ~/xsolis/sandbox
cd ~/xsolis/sandbox
```
Expected:
- direnv prints `direnv: loading ~/xsolis/.envrc` and `direnv: export +AWS_PROFILE +AWS_REGION ...`
- `echo $AWS_PROFILE` → `xsolis-dev`
- `cd ~ && echo $AWS_PROFILE` → empty string (unloaded)

If direnv prints `direnv: error .envrc is blocked`, the whitelist from Task 3 wasn't picked up; run `direnv allow ~/xsolis` once.

- [ ] **Step 7: Verify mise pulls Node 20 and .NET 8**

```bash
cd ~/xsolis/sandbox
mise install   # pulls Node 20 and .NET 8 SDK if missing (one-time)
node --version    # → v20.x.x
dotnet --version  # → 8.x.x (note: this dotnet is the system one from Task 1; mise's takes precedence inside the dir)
```

Expected: `node` reports v20.x. `dotnet` reports 8.x. (The first `mise install` may take a few minutes downloading.)

- [ ] **Step 8: Commit**

```bash
git add modules/xsolis.nix
git commit -m "feat(xsolis): scoped .envrc and mise pinning under ~/xsolis"
```

---

## Task 5: `xsolis-nuget-init` helper script

**Goal:** Provide a `xsolis-nuget-init` command on PATH that scaffolds a `nuget.config` in the current directory with `xsolis-nuget-store` plus any extra repos passed as args.

**Files:**
- Modify: `modules/xsolis.nix` (add `pkgs.writeShellScriptBin` to `home.packages`)

- [ ] **Step 1: Refactor `home.packages` to include the helper**

In `modules/xsolis.nix`, change the `home.packages` list to insert the `writeShellScriptBin` derivation. The full block becomes:

```nix
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
```

**Why the `''$` escaping?** Nix string interpolation uses `${...}`. To produce a literal `${...}` in the output (which the shell needs for `${VAR}` expansion), Nix requires `''${...}`. The `${dotnet-sdk_8}` references stay as-is because we want Nix to interpolate the store path of the SDK at build time — that pins the helper to the exact dotnet version managed by nix.

- [ ] **Step 2: Build**

Run: `nrb`
Expected: success.

- [ ] **Step 3: Activate**

Run: `nrs`
Expected: success.

- [ ] **Step 4: Verify the helper is on PATH**

```bash
which xsolis-nuget-init
```
Expected: `/etc/profiles/per-user/kadza/bin/xsolis-nuget-init` (or similar nix store path).

- [ ] **Step 5: Smoke-test the helper**

```bash
mkdir -p /tmp/xsolis-nuget-test && cd /tmp/xsolis-nuget-test
xsolis-nuget-init xsolis-cortex-core
cat nuget.config
```

Expected: output lines confirm both sources added; `nuget.config` contains:
- `<add key="xsolis-development/xsolis-nuget-store" value="https://xsolis-development-370752999763.d.codeartifact.us-east-1.amazonaws.com/nuget/xsolis-nuget-store/v3/index.json" />`
- `<add key="xsolis-development/xsolis-cortex-core" value="https://xsolis-development-370752999763.d.codeartifact.us-east-1.amazonaws.com/nuget/xsolis-cortex-core/v3/index.json" />`

Clean up: `rm -rf /tmp/xsolis-nuget-test`.

- [ ] **Step 6: Commit**

```bash
git add modules/xsolis.nix
git commit -m "feat(xsolis): xsolis-nuget-init helper script"
```

---

## Task 6: Shell PATH for `~/.dotnet/tools` and convenience aliases

**Goal:** Put `~/.dotnet/tools` (where dotnet global tools install) at the front of PATH so the CodeArtifact credential provider (installed in Task 7) is discoverable. Add two convenience aliases.

**Files:**
- Modify: `modules/shell.nix:42` (PATH session variable)
- Modify: `modules/shell.nix:174-175` (shell aliases — append two)

- [ ] **Step 1: Update PATH**

In `modules/shell.nix`, find line 42:

```nix
      PATH = "$HOME/.local/bin:$HOME/.local/share/mise/shims:$HOME/.config/jetbrains:$ANDROID_HOME/platform-tools:$PATH";
```

Change to:

```nix
      PATH = "$HOME/.local/bin:$HOME/.dotnet/tools:$HOME/.local/share/mise/shims:$HOME/.config/jetbrains:$ANDROID_HOME/platform-tools:$PATH";
```

- [ ] **Step 2: Add aliases**

In `modules/shell.nix`, find the `shellAliases` block. The current ending lines are around 172-174:

```nix
      # Tools
      zj = "zellij";
      tv = "television";
    };
```

Insert the two aliases just before the closing `};`:

```nix
      # Tools
      zj = "zellij";
      tv = "television";

      # Xsolis
      xsl-login = "aws sso login --sso-session xsolis";
      xsl-whoami = "aws sts get-caller-identity";
    };
```

- [ ] **Step 3: Build**

Run: `nrb`
Expected: success.

- [ ] **Step 4: Activate**

Run: `nrs`
Expected: success.

- [ ] **Step 5: Verify PATH and aliases**

In a new shell (`exec zsh`):
```bash
echo $PATH | tr ':' '\n' | grep -n dotnet
alias xsl-login
alias xsl-whoami
```

Expected:
- `$PATH` shows `$HOME/.dotnet/tools` somewhere near the front.
- `alias xsl-login` prints `xsl-login='aws sso login --sso-session xsolis'`.
- `alias xsl-whoami` prints `xsl-whoami='aws sts get-caller-identity'`.

- [ ] **Step 6: Commit**

```bash
git add modules/shell.nix
git commit -m "feat(shell): xsolis aliases and ~/.dotnet/tools on PATH"
```

---

## Task 7: Activation hook — install AWS CodeArtifact NuGet credential provider

**Goal:** On every `nrs`, ensure `AWS.CodeArtifact.NuGet.CredentialProvider` is installed as a dotnet global tool. Idempotent — `update` succeeds if already installed, otherwise we fall through to `install`.

**Files:**
- Modify: `modules/xsolis.nix` (add `home.activation` block)

- [ ] **Step 1: Add the activation hook**

In `modules/xsolis.nix`, append (still inside the attribute set):

```nix
  # ── AWS CodeArtifact NuGet credential provider ──
  # Installs as a dotnet global tool to ~/.dotnet/tools (on PATH from
  # modules/shell.nix). NuGet picks it up automatically when restoring
  # against codeartifact.*.amazonaws.com sources.
  # Idempotent: `update` is a no-op if same version is installed; `install`
  # is the first-time path. The `||` chain handles both.
  home.activation.aws-codeartifact-nuget = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run --quiet ${pkgs.dotnet-sdk_8}/bin/dotnet tool update -g AWS.CodeArtifact.NuGet.CredentialProvider \
      || run --quiet ${pkgs.dotnet-sdk_8}/bin/dotnet tool install -g AWS.CodeArtifact.NuGet.CredentialProvider
  '';
```

- [ ] **Step 2: Build**

Run: `nrb`
Expected: success.

- [ ] **Step 3: Activate (this triggers the hook)**

Run: `nrs`
Expected: success. Output may include lines about `Activating aws-codeartifact-nuget` and `Tool 'aws.codeartifact.nuget.credentialprovider' was successfully installed.` (or "was reinstalled" / "was already installed").

- [ ] **Step 4: Verify the tool is installed**

```bash
dotnet tool list -g
```

Expected: includes a line for `aws.codeartifact.nuget.credentialprovider`.

```bash
ls ~/.dotnet/tools
```

Expected: includes the credential provider executable.

- [ ] **Step 5: (Optional) Confirm it runs**

The provider is invoked by NuGet automatically — there's no useful direct `--help` output. The real verification is in Task 8 below (end-to-end). Skip this step if you're confident.

- [ ] **Step 6: Commit**

```bash
git add modules/xsolis.nix
git commit -m "feat(xsolis): install AWS CodeArtifact NuGet credential provider"
```

---

## Task 8: End-to-end verification

**Goal:** Confirm the whole pipeline works: SSO login → enter `~/xsolis/` → direnv loads → mise has Node 20 and .NET 8 → `xsolis-nuget-init` scaffolds a config → `dotnet restore` against CodeArtifact succeeds.

**Files:** None modified. This is a verification-only task.

- [ ] **Step 1: Start fresh — open a new shell**

```bash
exec zsh
```

- [ ] **Step 2: SSO login**

```bash
xsl-login
```

Expected: opens browser, completes auth, prints "Successfully logged into Start URL".

- [ ] **Step 3: Confirm identity outside `~/xsolis`**

```bash
cd ~
xsl-whoami
```

Expected: errors with "Unable to locate credentials" — because `AWS_PROFILE` isn't set outside `~/xsolis`. (This is the *desired* behavior: AWS commands at `~` shouldn't accidentally hit xsolis.)

- [ ] **Step 4: Enter `~/xsolis` — direnv should load**

```bash
mkdir -p ~/xsolis/e2e-test
cd ~/xsolis/e2e-test
```

Expected: direnv prints `direnv: loading ~/xsolis/.envrc` and lists exports.

- [ ] **Step 5: Confirm identity inside `~/xsolis`**

```bash
xsl-whoami
```

Expected: prints JSON identity with `Account: "370752999763"` and `Arn: ".../PowerUserAccess/..."`.

- [ ] **Step 6: Confirm runtime versions**

```bash
node --version    # → v20.x.x
dotnet --version  # → 8.x.x
```

If `mise` hasn't installed them yet, run `mise install` first.

- [ ] **Step 7: Confirm git identity inside `~/xsolis`**

```bash
git init e2e-git-test && cd e2e-git-test
git config user.email
git config user.name
```

Expected: `ukaric@xsolis.com` and `Uros Karic`. (This is from existing `modules/git.nix:93-103` — Task 8 just confirms it still works alongside the new module.)

```bash
cd .. && rm -rf e2e-git-test
```

- [ ] **Step 8: Scaffold and restore against CodeArtifact**

```bash
cd ~/xsolis/e2e-test
xsolis-nuget-init
dotnet new console
dotnet restore
```

Expected: `dotnet restore` completes. The credential provider authenticates against CodeArtifact silently using the SSO session. If it fails with "Unable to authenticate to CodeArtifact", check:
- `xsl-whoami` returns a valid identity (token not expired)
- `dotnet tool list -g` shows `aws.codeartifact.nuget.credentialprovider`
- `which xsolis-nuget-init` resolves

- [ ] **Step 9: Confirm AWS profile leaves the env on `cd` away**

```bash
cd ~
echo "$AWS_PROFILE"
```

Expected: empty line.

- [ ] **Step 10: Clean up the test directory**

```bash
rm -rf ~/xsolis/e2e-test
```

- [ ] **Step 11: Final commit (no changes — just a marker)**

There's nothing to commit from Task 8 itself. If all previous tasks committed cleanly, the branch is ready. Skip this step.

---

## Spec Coverage Self-Review

Cross-checking each spec section against tasks:

| Spec section | Covered by |
|---|---|
| Module structure (`modules/xsolis.nix`) | Task 1 |
| dotnet-sdk_8, granted, liquibase | Task 1 |
| `~/.aws/config` declarative | Task 2 |
| `~/xsolis/.envrc` | Task 4 |
| `~/xsolis/.mise.toml` | Task 4 |
| direnv whitelist `~/xsolis` | Task 3 |
| `~/.dotnet/tools` on PATH | Task 6 |
| `xsl-login`, `xsl-whoami` aliases | Task 6 |
| `xsolis-nuget-init` helper | Task 5 |
| CodeArtifact credential provider activation | Task 7 |
| `home/kadza.nix` import | Task 1 |
| End-to-end verification | Task 8 |

All spec items map to a task. Bootstrap sequence section in spec is covered implicitly by Tasks 1-7 + Task 8's verification flow.
