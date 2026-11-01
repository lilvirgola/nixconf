# `nixos/` — NixOS Configurations & Modules

## What Goes Here?

Everything specific to **NixOS** lives under this directory, split into two clear layers:

1. **[`features/`](./features/)**: Reusable building blocks (`flake.nixosModules.<featureName>`). Features define *what* a capability needs (services, packages, kernel/hardware flags) without hardcoding which machine it runs on.
2. **[`hosts/`](./hosts/)**: Concrete machines (`flake.nixosConfigurations.<hostName>`). Each host simply imports the feature modules it needs and sets its machine-specific hostname, bootloader, and hardware scan.
