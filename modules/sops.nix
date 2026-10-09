{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Install sops and age for CLI usage
  home.packages = with pkgs; [
    sops
    age
  ];

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../secrets/secrets.yaml;

    # PATH for the sops-nix launchd agent on macOS. It shells out to system
    # tools that live outside /usr/bin: getconf (/usr/bin), but also newfs_hfs
    # and mount (/sbin) and diskutil (/usr/sbin) — sops-install-secrets creates
    # an HFS RAM-disk to hold the decrypted secrets. Without /sbin:/usr/sbin the
    # agent fails: `newfs_hfs: executable file not found in $PATH`.
    environment.PATH = lib.mkForce "/usr/bin:/bin:/sbin:/usr/sbin";

    # Files at a `path` become symlinks into the sops-nix RAM disk. An existing
    # regular file at that path is deleted without a backup, and the target is
    # read-only, so tools that rewrite their own config (opencode, rclone
    # OAuth remotes) must not be managed here.
    secrets = {
      ssh_id_ed25519 = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519";
        mode = "0600";
      };

      # Only consumed by the templates below.
      npm_importok_token = { };
      rclone_r2_access_key_id = { };
      rclone_r2_secret_access_key = { };
      # Contains the Cloudflare account ID; kept out of this public repo.
      rclone_r2_endpoint = { };

      # opencode rewrites opencode.json itself, so the file stays app-owned and
      # references this secret as `{file:~/.config/sops-nix/secrets/context7_api_key}`.
      context7_api_key = { };

      # Read by the xsolis-* Claude skills through the token paths named in the
      # app-owned ~/.config/xsolis/config.json.
      xsolis_bitbucket_token.path = "${config.home.homeDirectory}/.config/xsolis/bitbucket_token";
      xsolis_confluence_pat.path = "${config.home.homeDirectory}/.config/xsolis/confluence_pat";
      xsolis_jira_pat.path = "${config.home.homeDirectory}/.config/xsolis/jira_pat";
      xsolis_sonar_token.path = "${config.home.homeDirectory}/.config/xsolis/sonar_token";
      xsolis_xpas_db_dev2.path = "${config.home.homeDirectory}/.config/xsolis/xpas_db_dev2";
    };

    # Static-key configs only; nothing here refreshes credentials in place.
    templates = {
      npmrc = {
        path = "${config.home.homeDirectory}/.npmrc";
        content = ''
          @importok:registry=https://npm.importok.io/
          //npm.importok.io/:_authToken=${config.sops.placeholder.npm_importok_token}
        '';
      };

      # The R2 remote uses static S3 keys; rclone only rewrites this file for
      # OAuth token refreshes or `rclone config` edits.
      "rclone.conf" = {
        path = "${config.home.homeDirectory}/.config/rclone/rclone.conf";
        content = ''
          [r2]
          type = s3
          provider = Cloudflare
          access_key_id = ${config.sops.placeholder.rclone_r2_access_key_id}
          secret_access_key = ${config.sops.placeholder.rclone_r2_secret_access_key}
          endpoint = ${config.sops.placeholder.rclone_r2_endpoint}
        '';
      };
    };

  };
}
