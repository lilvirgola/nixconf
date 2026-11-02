{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    patchedNoctalia = pkgs.noctalia-shell.overrideAttrs (oldAttrs: {
      postPatch =
        (oldAttrs.postPatch or "")
        + ''
          # Mango implements ext-workspace-v1 (standard Wayland protocol) and wlr-foreign-toplevel,
          # but does NOT implement zdwl_ipc_manager_v2 (DWL-IPC).
          # Route Mango to extWorkspaceComponent instead of the broken DwlIpc-based mangoComponent.
          substituteInPlace Services/Compositor/CompositorService.qml \
            --replace-fail \
              'backendLoader.sourceComponent = mangoComponent;' \
              'isExtWorkspace = true; isMango = false; backendLoader.sourceComponent = extWorkspaceComponent;'

          # In ExtWorkspaceService, provide a fallback logout command using mmsg dispatch quit
          substituteInPlace Services/Compositor/ExtWorkspaceService.qml \
            --replace-fail \
              'Logger.w("ExtWorkspaceService", "logout: XDG_SESSION_ID unset; use session menu custom command or compositor-specific backend");' \
              'Quickshell.execDetached(["mmsg", "dispatch", "quit"]);'
        '';
    });
  in {
    packages.myNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
      package = patchedNoctalia;
      settings =
        (builtins.fromJSON
          (builtins.readFile ./noctalia.json)).settings;
    };
  };
}
