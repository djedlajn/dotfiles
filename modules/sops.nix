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

    secrets = {
      ssh_id_ed25519 = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519";
        mode = "0600";
      };
    };

  };
}
