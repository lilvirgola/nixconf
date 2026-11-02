# `nixos/hosts/` — Machine Definitions & Host Assemblies

Each subdirectory in `nixos/hosts/<hostname>/` defines a complete, independent machine configuration exposed as `flake.nixosConfigurations.<hostname>`.

---

## Current Hosts Comparison Matrix

| Feature | Virtual Machine (`#vm`) | Physical Laptop (`#laptop`) |
| :--- | :--- | :--- |
| **Target Architecture** | QEMU / KVM Virtual Machine | Physical Portable Workstation |
| **Bootloader** | GRUB (`boot.loader.grub.device = "/dev/vda"`) | UEFI systemd-boot (`boot.loader.systemd-boot`) |
| **Boot Limit** | Last 10 generations | Last 10 generations |
| **Kernel** | `linuxPackages_latest` | `linuxPackages_latest` |
| **SSH Daemon (`sshd`)** | **Enabled** by default (`services.openssh.enable = true`) | **Disabled** by default (`services.openssh.enable = false`) |
| **Graphics & GPU** | Virtual display (QXL / Bochs / VirtIO) | Nvidia Proprietary + PRIME Offload |
| **Display Manager** | SDDM + Catppuccin Mocha theme | SDDM + Catppuccin Mocha theme |
| **Desktop Session** | MangoWM + Noctalia floating bar | MangoWM + Noctalia floating bar |
| **Power Management** | Disabled (Virtual) | UPower, `power-profiles-daemon`, lid switch suspend |
| **Bluetooth** | Disabled | BlueZ + Blueman GUI applet (`services.blueman`) |
| **Development Suite** | Full (Python uv, Go, Rust, PHP, JDK 21, LaTeX) | Full (Python uv, Go, Rust, PHP, JDK 21, LaTeX) |
| **Security & CTF Suite** | Full (Ghidra, Pwndbg, Sage, Wireshark, Burp) | Full (Ghidra, Pwndbg, Sage, Wireshark, Burp) |
| **Gaming** | Steam & GameMode | Steam, GameMode, Nvidia offload |

---

## Standard 3-File Host Structure

Every host follows an identical 3-file convention:

```text
nixos/hosts/<hostname>/
├── default.nix          # Flake output definition (nixosSystem call)
├── configuration.nix    # Feature module imports & host-specific overrides
└── hardware.nix         # Hardware scan (file systems, kernel modules, CPU microcode)
```

### 1. `default.nix`
Wires the system up using `inputs.nixpkgs.lib.nixosSystem`:
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

### 2. `configuration.nix`
Declares `flake.nixosModules.<hostname>Configuration`, selecting features and setting host settings:
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

    # UEFI Bootloader
    boot.loader.systemd-boot.enable = true;
    boot.loader.systemd-boot.configurationLimit = 10;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelPackages = pkgs.linuxPackages_latest;
  };
}
```

### 3. `hardware.nix`
Wraps the output of `nixos-generate-config --show-hardware-config`:
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

---

## Automated Provisioning with `bootstrap.sh`

To set up a fresh machine automatically:
```bash
# Run the interactive bootstrapper:
bash bootstrap.sh

# Or non-interactively for the laptop:
bash bootstrap.sh --host laptop
```
The script will:
1. Probe hardware devices and generate `hardware.nix`.
2. Back up any prior configuration.
3. Prompt to set user passwords.
4. Verify flake formatting and evaluation.
5. Rebuild and activate the system.

---

## Adding a New Host Manually

1. **Create Directory**:
   ```bash
   mkdir -p nixos/hosts/my-desktop
   ```
2. **Generate Hardware Scan**:
   ```bash
   nixos-generate-config --show-hardware-config > nixos/hosts/my-desktop/hardware.nix
   ```
   Wrap the output in `{ flake.nixosModules.myDesktopHardware = { config, lib, pkgs, modulesPath, ... }: { ... }; }`.
3. **Create `configuration.nix` & `default.nix`** using the templates above.
4. **Stage in Git**:
   ```bash
   git add nixos/hosts/my-desktop
   ```
5. **Switch**:
   ```bash
   sudo nixos-rebuild switch --flake .#my-desktop
   ```
Because `flake.nix` uses the Dendritic auto-importer, `my-desktop` is immediately exposed as `.#my-desktop` without touching `flake.nix`!
