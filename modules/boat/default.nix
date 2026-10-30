# Boat (boat.dev) sandbox CLI. Upstream only ships `curl … | sh`, which
# rewrites ~/.zshrc and ~/.zshenv to add a PATH block and a `boat` shell
# function. Both files are read-only home-manager links, so that installer
# aborts half-way. This module installs the same release binary and declares
# the same shell integration. Sign-in state stays app-owned under
# ~/Library/Application Support/ascii/boat (run `boat onboard` once).
#
# Bump with ./update.sh: it pins release.json to the release boat.dev serves.
{ pkgs, lib, ... }:
let
  release = lib.importJSON ./release.json;

  boat = pkgs.stdenvNoCC.mkDerivation {
    pname = "boat";
    inherit (release) version;
    src = pkgs.fetchurl {
      url = "https://github.com/ariana-dot-dev/agent-server/releases/download/boat-cli-v${release.version}/boat-darwin-arm64";
      inherit (release) hash;
    };
    dontUnpack = true;
    # Prebuilt, ad-hoc signed Mach-O: stripping would break the signature.
    dontStrip = true;
    nativeBuildInputs = [ pkgs.makeWrapper ];
    installPhase = ''
      runHook preInstall
      install -Dm755 $src $out/libexec/boat
      # The CLI updates itself unless told not to. The store path is
      # read-only, so updates come from ./update.sh instead.
      makeWrapper $out/libexec/boat $out/bin/boat --set BOAT_NO_UPDATE 1
      # The script is static; it calls `boat ids` from PATH for sandbox IDs.
      mkdir -p $out/share/boat
      HOME=$TMPDIR $out/bin/boat completions zsh > $out/share/boat/completion.zsh
      runHook postInstall
    '';
    meta.mainProgram = "boat";
  };
in
{
  home.packages = [ boat ];

  # Port of the function the upstream installer appends to ~/.zshrc. The CLI
  # writes the new sandbox ID or conversation ID to the *_FILE path it gets;
  # exporting it makes later `boat` commands default to that sandbox.
  programs.zsh.initContent = ''
    source ${boat}/share/boat/completion.zsh

    boat() {
      local id_file=$(mktemp) convo_file=$(mktemp) id convo rc
      BOAT_CURRENT_ID_FILE=$id_file BOAT_CURRENT_CONVO_FILE=$convo_file command boat "$@"
      rc=$?
      if (( rc == 0 )); then
        case $1 in
          new|start|fork)
            id=''${$(<$id_file)//[[:space:]]/}
            [[ -n $id ]] && export BOAT_CURRENT_ID=$id
            ;;
          prompt)
            IFS= read -r convo < $convo_file
            [[ -n $convo ]] && export BOAT_CURRENT_CONVO=$convo
            ;;
        esac
      fi
      rm -f $id_file $convo_file
      return $rc
    }
  '';
}
