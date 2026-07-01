{
  description = "nix-darwin system flake with home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # mise pinned to a nixpkgs rev whose build is cached on cache.nixos.org.
    # nixpkgs-unstable's mise 2026.6.11 isn't cached and its checkPhase fails
    # in the darwin sandbox (oci::layer setuid-bit test), forcing a ~14m build.
    # Bump this rev once a newer cached mise is available.
    nixpkgs-mise.url = "github:NixOS/nixpkgs/2785ccf81c58da1ebd3a179e9a6aac4faec7fee8"; # mise 2026.6.5
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, rust-overlay, sops-nix, treefmt-nix, nixpkgs-mise }:
  let
    username = "kadza";
    system = "aarch64-darwin";
  in
  {
    darwinConfigurations."Uross-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      inherit system;
      modules = [
        ./hosts/Uross-MacBook-Pro.nix
        home-manager.darwinModules.home-manager
        {
          nixpkgs.overlays = [
            rust-overlay.overlays.default
            (final: prev: {
              mise = nixpkgs-mise.legacyPackages.${system}.mise;
              direnv = prev.direnv.overrideAttrs (old: {
                env = (old.env or { }) // {
                  CGO_ENABLED = "1";
                };
                doCheck = false;
              });
              nushell = prev.nushell.overrideAttrs (old: {
                doCheck = false;
              });
            })
          ];
          nixpkgs.config.allowUnfreePredicate = pkg:
            builtins.elem (nixpkgs.lib.getName pkg) [
              "packer"  # HashiCorp BSL license
            ];
        }
        {
          home-manager = {
            useGlobalPkgs = true;
            backupFileExtension = "backup";
            users.${username} = import ./home/kadza.nix;
            sharedModules = [
              sops-nix.homeManagerModules.sops
            ];
          };
        }
      ];
    };

    # Formatter for `nix fmt`
    formatter.${system} = treefmt-nix.lib.mkWrapper nixpkgs.legacyPackages.${system} {
      projectRootFile = "flake.nix";
      programs.nixfmt.enable = true;
    };
  };
}
