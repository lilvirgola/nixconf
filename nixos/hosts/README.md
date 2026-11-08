# Machine definitions in nixos/hosts/

Each subdirectory in `nixos/hosts/<hostname>/` defines a machine configuration exposed as `flake.nixosConfigurations.<hostname>`.

## Hosts comparison

| Feature | Virtual machine (`#vm`) | Physical laptop (`#laptop`) |
| :--- | :--- | :--- |
| Target architecture | QEMU / KVM virtual machine | Physical laptop workstation |
| Bootloader | GRUB (`boot.loader.grub.device = "/dev/vda"`) | UEFI systemd-boot (`boot.loader.systemd-boot`) |
| Boot limit | Last 10 generations | Last 10 generations |
| Kernel | `linuxPackages_latest` | `linuxPackages_latest` |
| SSH daemon (`sshd`) | Enabled (`services.openssh.enable = true`) | Disabled (`services.openssh.enable = false`) |
| Graphics | Virtual display (QXL / Bochs / VirtIO) | Nvidia proprietary with PRIME offload |
| Display manager | SDDM with Catppuccin Mocha theme | SDDM with Catppuccin Mocha theme |
| Desktop session | MangoWM with Noctalia floating bar | MangoWM with Noctalia floating bar |
| Power management | Disabled | UPower, `power-profiles-daemon`, lid switch suspend |
| Bluetooth | Disabled | BlueZ and Blueman applet (`services.blueman`) |
| Development suite | Full (Python uv, Go, Rust, PHP, JDK 21, LaTeX) | Full (Python uv, Go, Rust, PHP, JDK 21, LaTeX) |
| Security suite | Full (Ghidra, Pwndbg, Sage, Wireshark, Burp) | Full (Ghidra, Pwndbg, Sage, Wireshark, Burp) |
| Gaming | Steam and GameMode | Steam, GameMode, Nvidia offload |

## Host file structure

Each host uses three files:

```text
nixos/hosts/<hostname>/
├── default.nix          # Flake output definition (nixosSystem call)
├── configuration.nix    # Feature module imports and host overrides
└── hardware.nix         # Hardware scan (filesystems, kernel modules, CPU microcode)
```

### 1. default.nix
Builds the system with `inputs.nixpkgs.lib.nixosSystem`:
```nix
{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.myhost = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {inherit inputs self;};
    modules = [
      self.nixosModules.myhostConfiguration
    ];
  };
}
```

### 2. configuration.nix
Declares `flake.nixosModules.<hostname>Configuration`, selecting features and setting host options:
```nix
{self, ...}: {
  flake.nixosModules.myhostConfiguration = {pkgs, ...}: {
    imports = [
      self.nixosModules.myhostHardware
      self.nixosModules.base
      self.nixosModules.mangowm
      self.nixosModules.desktopApps
      self.nixosModules.dev
      self.nixosModules.security
    ];

    networking.hostName = "myhost";

    boot.loader.systemd-boot.enable = true;
    boot.loader.systemd-boot.configurationLimit = 10;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelPackages = pkgs.linuxPackages_latest;
  };
}
```

### 3. hardware.nix
Contains hardware-specific configuration from `nixos-generate-config --show-hardware-config`:
```nix
{
  flake.nixosModules.myhostHardware = {
    config,
    lib,
    pkgs,
    modulesPath,
    ...
  }: {
    # Generated hardware configuration...
  };
}
```

## Provisioning with bootstrap.sh

To provision a new machine:
```bash
# Interactive setup:
bash bootstrap.sh

# Non-interactive for the laptop:
bash bootstrap.sh --host laptop
```

The script:
1. Detects hardware devices and generates `hardware.nix`.
2. Backs up existing configuration.
3. Prompts for user passwords.
4. Checks flake formatting and evaluation.
5. Rebuilds and activates the system.

## Adding a new host manually

1. Create the host directory:
   ```bash
   mkdir -p nixos/hosts/my-desktop
   ```
2. Generate the hardware scan:
   ```bash
   nixos-generate-config --show-hardware-config > nixos/hosts/my-desktop/hardware.nix
   ```
   Wrap the output in `{ flake.nixosModules.myDesktopHardware = { config, lib, pkgs, modulesPath, ... }: { ... }; }`.
3. Create `configuration.nix` and `default.nix` using the templates above.
4. Stage files in Git:
   ```bash
   git add nixos/hosts/my-desktop
   ```
5. Apply configuration:
   ```bash
   sudo nixos-rebuild switch --flake .#my-desktop
   ```
