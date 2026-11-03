# Fresh Installation Guide: From Zero to Virgola's NixOS

This guide walks you through a clean, from-scratch installation of **Virgola's NixOS Desktop & Security Suite** on physical hardware (`laptop` host).

---

## 📋 Table of Contents
1. [Pre-Installation Checklist](#1-pre-installation-checklist)
2. [Booting the Live Environment](#2-booting-the-live-environment)
3. [Disk Partitioning & Formatting](#3-disk-partitioning--formatting)
4. [Mounting the Filesystem Layout](#4-mounting-the-filesystem-layout)
5. [Cloning nixconf & Automated Bootstrapping](#5-cloning-nixconf--automated-bootstrapping)
6. [First Boot & System Initialization](#6-first-boot--system-initialization)
7. [Post-Installation Verification Checklist](#7-post-installation-verification-checklist)

---

## 1. Pre-Installation Checklist

- [x] **Data Backup**: Ensure your files, personal repositories, SSH keys (`~/.ssh`), and browser profiles are backed up to external storage (e.g. USB drive or external hard drive).
- [ ] **NixOS Live USB**: Download the latest **NixOS Graphical or Minimal ISO** (`x86_64`) from [nixos.org/download](https://nixos.org/download.html).
  Write to a USB flash drive:
  ```bash
  # Identify your USB drive (e.g. /dev/sdb, /dev/sdc)
  lsblk

  # Flash ISO (Replace /dev/sdX with your USB flash drive)
  sudo dd if=nixos.iso of=/dev/sdX bs=4M status=progress oflag=sync
  ```
- [ ] **BIOS / UEFI Settings**:
  - **UEFI Mode**: Enabled.
  - **Secure Boot**: Temporarily disabled.
  - **Storage Controller**: AHCI mode (not RAID / Intel RST).

---

## 2. Booting the Live Environment

1. Insert the USB drive and power on the machine while pressing `F12` (or `F2`/`Del` depending on your motherboard) to open the boot menu.
2. Select the UEFI USB boot entry.
3. Once booted into the live installer shell, establish network connectivity:

### Connecting via Wi-Fi (`iwctl` or `nmcli`)
```bash
# Option A: If using Minimal ISO (iwctl):
iwctl
[iwd]# station wlan0 scan
[iwd]# station wlan0 get-networks
[iwd]# station wlan0 connect "<YOUR_WIFI_SSID>"
[iwd]# exit

# Option B: If using Graphical ISO (NetworkManager):
nmcli device wifi connect "<YOUR_WIFI_SSID>" password "<YOUR_WIFI_PASSWORD>"
```

### Test Connectivity
```bash
ping -c 3 nixos.org
```

---

## 3. Disk Partitioning & Formatting

> [!CAUTION]
> The following commands will erase the selected target drive. Ensure any external backup drives are detached before proceeding, or double-check disk names with `lsblk`.

### Step 3.1: Identify Your Target Drive
Run `lsblk` to identify the internal drive you want to install NixOS onto (e.g. `/dev/nvme0n1` or `/dev/sda`):
```bash
lsblk
DISK="/dev/nvme0n1" # Set your target disk variable
```

### Step 3.2: Create GPT Partition Table
```bash
# 1. Create a clean GPT partition table
parted "$DISK" -- mklabel gpt

# 2. Partition 1: EFI System Partition (1 GiB)
parted "$DISK" -- mkpart ESP fat32 1MiB 1025MiB
parted "$DISK" -- set 1 esp on

# 3. Partition 2: Root Filesystem (Remaining Disk Space)
parted "$DISK" -- mkpart primary 1025MiB 100%
```

> [!NOTE]
> If using an NVMe drive (`/dev/nvme0n1`), the partitions are `${DISK}p1` and `${DISK}p2`.  
> If using an SSD/HDD (`/dev/sda`), the partitions are `${DISK}1` and `${DISK}2`.

### Step 3.3: Format Partitions
```bash
# EFI Partition (FAT32)
mkfs.vfat -F 32 -n BOOT "${DISK}p1" # Or "${DISK}1"

# Root Partition with Btrfs
mkfs.btrfs -f -L nixos "${DISK}p2" # Or "${DISK}2"
```

### Step 3.4: Create Btrfs Subvolumes
Creating subvolumes provides clean separation between system snapshots, user data, and the immutable Nix store:
```bash
# Temporary mount to create subvolumes
mount "${DISK}p2" /mnt

btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
btrfs subvolume create /mnt/@log

umount /mnt
```

---

## 4. Mounting the Filesystem Layout

Mount the subvolumes with `zstd` transparent compression and mount the EFI boot partition:

```bash
# Mount root subvolume
mount -o compress=zstd:3,subvol=@ "${DISK}p2" /mnt

# Create mount points
mkdir -p /mnt/{home,nix,var/log,boot}

# Mount secondary subvolumes
mount -o compress=zstd:3,subvol=@home "${DISK}p2" /mnt/home
mount -o compress=zstd:3,noatime,subvol=@nix "${DISK}p2" /mnt/nix
mount -o compress=zstd:3,subvol=@log "${DISK}p2" /mnt/var/log

# Mount EFI partition
mount "${DISK}p1" /mnt/boot

# Verify mount hierarchy
lsblk -f "$DISK"
```

---

## 5. Cloning nixconf & Automated Bootstrapping

### Step 5.1: Clone the Repository into Target Root
```bash
mkdir -p /mnt/etc/nixos
git clone https://github.com/lilvirgola/nixconf.git /mnt/etc/nixos
cd /mnt/etc/nixos
```

### Step 5.2: Generate Hardware Profile
Run `nixos-generate-config` targeting the mounted root:
```bash
nixos-generate-config --root /mnt
```

### Step 5.3: Run the Automated Bootstrapper
Execute `bootstrap.sh` targeting the `laptop` host. The script will:
1. Probe hardware and auto-wrap the generated partition & hardware configuration into `flake.nixosModules.laptopHardware`.
2. Stage all configuration files in Git.
3. Validate flake evaluation and syntax.
4. Execute `nixos-install --flake .#laptop`.
5. Prompt you to set your user password for `virgola`.

```bash
./bootstrap.sh --host laptop
```

*(Manual installation alternative without running the script)*:
```bash
# Install system directly using the flake:
nixos-install --flake .#laptop --root /mnt

# Set password for virgola
nixos-enter --root /mnt -c "passwd virgola"
```

---

## 6. First Boot & System Initialization

1. Unmount all filesystems and reboot:
   ```bash
   umount -R /mnt
   reboot
   ```
2. Remove the USB installer drive when prompted.
3. **SDDM Display Manager** will load with the Catppuccin Astronaut theme.
4. Log in as user `virgola` with the password configured during installation.
5. You will enter the **Pure MangoWM + Noctalia v5** Wayland desktop environment.

---

## 7. Post-Installation Verification Checklist

### 1. Hybrid Graphics (NVIDIA PRIME Offload)
Check that the integrated GPU powers the desktop while the NVIDIA GPU powers on-demand applications:
```bash
# Verify NVIDIA GPU driver is active
nvidia-smi

# Test on-demand GPU offload
prime-run glxinfo | grep "OpenGL renderer"
```

### 2. On-Demand Ollama (0 VRAM Idle)
Ollama is configured with CUDA acceleration, but is kept stopped on boot by default to preserve battery:
```bash
# 1. Check status (should be inactive / dead, using 0 VRAM)
ollama-stat

# 2. Launch Ollama daemon on-demand (passwordless helper)
ollama-up

# 3. Pull and run a test model
ollama run llama3

# 4. Release VRAM and stop daemon when finished
ollama-down
```

### 3. MediaTek MT7921 Bluetooth Sleep/Wake Fix
Verify that the resume service is active and that Bluetooth persists after laptop lid sleep:
```bash
# Inspect service status
systemctl status mt7921-bt-resume

# Test sleep/wake:
# Close the laptop lid, wait 10 seconds, open it, and test Bluetooth pairing:
bluetoothctl devices
```

### 4. Network & VPN Daemons
```bash
# Tailscale mesh VPN
sudo tailscale up

# Mullvad VPN
mullvad status
```

### 5. Game Controllers & Microcontrollers
```bash
# DualSense Controller (Plug in via USB or pair via BT)
dualsensectl battery

# Microcontroller access (PlatformIO / Arduino)
pio device list
```

### 6. Restoring Personal Data from External Backup
Connect your external backup drive:
```bash
# Identify your backup drive partition
lsblk -f

# Mount external drive (NTFS, Ext4, and Btrfs are supported natively)
sudo mkdir -p /media/backup
sudo mount /dev/sdX1 /media/backup # Replace /dev/sdX1 with your backup partition

# Restore SSH keys & configurations as needed:
cp -r /media/backup/.ssh ~/.ssh
chmod 700 ~/.ssh && chmod 600 ~/.ssh/*

# Restore project repos or documents
rsync -avh --progress /media/backup/projects/ ~/projects/
```
