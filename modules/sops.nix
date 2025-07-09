{ config, pkgs, lib, ... }: {
  # Install sops and age for CLI usage
  home.packages = with pkgs; [
    sops
    age
  ];

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../secrets/secrets.yaml;

    # Fix PATH for launchd agent on macOS (needs getconf)
    environment.PATH = lib.mkForce "/usr/bin:/bin";

    secrets = {
      ssh_id_ed25519 = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519";
        mode = "0600";
      };
      ssh_green_ed25519 = {
        path = "${config.home.homeDirectory}/.ssh/green_ed25519";
        mode = "0600";
      };
      work_email = {};
    };

    templates."gitconfig-greenlight" = {
      content = ''
        [user]
            email = ${config.sops.placeholder.work_email}
      '';
      path = "${config.home.homeDirectory}/.gitconfig-greenlight";
    };
  };
}
