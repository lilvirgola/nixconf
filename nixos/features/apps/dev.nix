{self, ...}: {
  flake.nixosModules.dev = {pkgs, ...}: {
    imports = [
      self.nixosModules.antigravity
      self.nixosModules.docker
    ];

    # Modern Antigravity AI platform with native host execution (sudo enabled)
    programs.antigravity.enable = true;

    # PlatformIO microcontroller udev rules (ESP32, STM32, Arduino)
    services.udev.packages = with pkgs; [
      platformio-core.udev
    ];

    environment.sessionVariables = {
      UV_PYTHON_DOWNLOADS = "automatic";
    };

    # Lean everyday dev tools; use `ninit` templates for per-project stacks
    # (Rust, Go, LaTeX, Embedded, SDR, Godot, Java, C#, Haskell, etc.)
    environment.systemPackages = with pkgs; [
      uv
      (python3.withPackages (ps:
        with ps; [
          pip
          dbus-python
          pygobject3
          cryptography
          pyopenssl
        ]))
      vscode
      gcc
      gnumake
      cmake
      pkg-config
      act
      docker-compose
      distrobox
    ];
  };
}
