{...}: {
  perSystem = {pkgs, ...}: {
    packages.deploy = pkgs.writeShellApplication {
      name = "deploy";
      runtimeInputs = with pkgs; [
        nixos-rebuild
        openssh
        coreutils
      ];
      text = ''
        usage() {
          cat <<'EOF'
        Usage: deploy <host> [user@target] [switch|test|boot|dry-activate] [--remote-build]

        Deploy a nixconf NixOS host configuration over SSH / Tailscale.

        Examples:
          deploy server
          deploy server admin@100.64.0.12
          deploy raspberrypi virgola@raspberrypi --remote-build
          deploy vm virgola@192.168.122.50 test
        EOF
        }

        if [[ $# -lt 1 || "''${1:-}" == "-h" || "''${1:-}" == "--help" ]]; then
          usage
          exit 0
        fi

        host="$1"
        shift

        target="virgola@$host"
        action="switch"
        remote_build=false

        while [[ $# -gt 0 ]]; do
          case "$1" in
            switch|test|boot|dry-activate)
              action="$1"
              shift
              ;;
            --remote-build)
              remote_build=true
              shift
              ;;
            -*)
              echo "Unknown option: $1" >&2
              usage
              exit 1
              ;;
            *)
              target="$1"
              shift
              ;;
          esac
        done

        # Cross-arch builds (e.g. aarch64 raspberrypi from x86_64) default to building on target
        if [[ "$host" == "raspberrypi" && "$(uname -m)" != "aarch64" ]]; then
          remote_build=true
        fi

        args=(
          "$action"
          --flake ".#$host"
          --target-host "$target"
          --sudo
          --ask-sudo-password
        )

        if [[ "$remote_build" == true ]]; then
          args+=(--build-host "$target")
        fi

        echo "[*] Deploying .#$host -> $target ($action)..."
        exec nixos-rebuild "''${args[@]}"
      '';
    };
  };
}
