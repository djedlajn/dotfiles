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
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, rust-overlay, sops-nix, treefmt-nix }:
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
              direnv = prev.direnv.overrideAttrs (old: {
                env = (old.env or { }) // {
                  CGO_ENABLED = "1";
                };
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
