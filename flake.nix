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
    # Determinate Nix's nix-darwin module: declarative Nix settings
    # (nix.custom.conf) while Determinate manages the daemon.
    determinate.url = "github:DeterminateSystems/determinate";
    # Claude Code packaged from Anthropic's releases (updated hourly,
    # binary cache at claude-code.cachix.org). No nixpkgs follows on
    # purpose — following would change hashes and miss their cache.
    claude-code-nix.url = "github:sadjow/claude-code-nix";
    # Codex CLI packaged from OpenAI's releases by the same author (updated
    # hourly, binary cache at codex-cli.cachix.org). Same rule as above: no
    # nixpkgs follows, or hashes change and miss their cache.
    codex-cli-nix.url = "github:sadjow/codex-cli-nix";
    # herdr — TUI agent multiplexer (runs coding agents side by side in the
    # terminal). Built from source; follows our nixpkgs/rust-overlay so the
    # toolchain and closure dedupe instead of pulling a second copy.
    herdr = {
      url = "github:ogulcancelik/herdr";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      rust-overlay,
      sops-nix,
      treefmt-nix,
      determinate,
      claude-code-nix,
      codex-cli-nix,
      herdr,
    }:
    let
      username = "kadza";
      system = "aarch64-darwin";
      treefmtEval = treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} {
        projectRootFile = "flake.nix";
        programs.nixfmt.enable = true;
      };
    in
    {
      darwinConfigurations."Uross-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        # Platform is set via nixpkgs.hostPlatform in the host module.
        modules = [
          ./hosts/Uross-MacBook-Pro.nix
          # Declarative Nix settings (nix.custom.conf) with Determinate Nix
          # managing the daemon; sets nix.enable = false internally.
          determinate.darwinModules.default
          # Record the git revision of this flake in each generation
          # (shown by `darwin-rebuild --list-generations`).
          { system.configurationRevision = self.rev or self.dirtyRev or null; }
          home-manager.darwinModules.home-manager
          {
            nixpkgs.overlays = [
              rust-overlay.overlays.default
            ];
            nixpkgs.config.allowUnfreePredicate =
              pkg:
              builtins.elem (nixpkgs.lib.getName pkg) [
                "packer" # HashiCorp BSL license
              ];
          }
          {
            home-manager = {
              useGlobalPkgs = true;
              # Install user packages to /etc/profiles/per-user instead of
              # ~/.nix-profile (recommended; likely future default).
              useUserPackages = true;
              backupFileExtension = "backup";
              # Expose flake inputs to home modules (e.g. claude-code-nix).
              extraSpecialArgs = { inherit inputs; };
              users.${username} = import ./home/kadza.nix;
              sharedModules = [
                sops-nix.homeManagerModules.sops
              ];
            };
          }
        ];
      };

      # Formatter for `nix fmt`
      formatter.${system} = treefmtEval.config.build.wrapper;

      # `nix flake check` (nfc alias): builds the full system closure
      # (catching option errors and warnings before a switch) and
      # verifies formatting.
      checks.${system} = {
        darwin-system = self.darwinConfigurations."Uross-MacBook-Pro".system;
        formatting = treefmtEval.config.build.check self;
      };
    };
}
