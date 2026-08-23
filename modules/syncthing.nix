# Syncthing — continuous folder sync with cc-remote (~/sync on both ends).
# Runs as a launchd user agent. Web UI: http://127.0.0.1:8384
# Pairing with the box (device id + shared folder) happens in the UI once,
# or gets declared here after first run; state lives outside nix on purpose.
{ ... }:
{
  services.syncthing = {
    enable = true;
  };
}
