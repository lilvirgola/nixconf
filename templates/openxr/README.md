# OpenXR VR development workspace

Provides `godot_4`, `openxr-loader`, Vulkan headers/loader/tools, Wayland development libraries, C/C++ (`gcc`, `cmake`, `ninja`, `clang-tools`), and Rust (`cargo`, `rustc`, `rust-analyzer`, `clippy`, `rustfmt`).

## Usage

Start the WiVRn server first (`wivrn-dashboard`) and connect the Meta Quest 3, then launch Godot or your OpenXR binary:

```bash
# Standard / desktop GPU
godot4

# Hybrid Nvidia laptop (PRIME offload)
nvidia-offload godot4
```

Verify Vulkan and OpenXR environment readiness with `vulkaninfo --summary`.

