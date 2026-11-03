#include <iostream>
#include <string>
#include <vector>

int main() {
    std::vector<std::string> tools = {"Clang", "CMake", "Ninja", "GDB", "Nix"};

    std::cout << "🚀 Modern C++ project initialized successfully!\n";
    std::cout << "Configured toolchain components:\n";
    for (const auto& tool : tools) {
        std::cout << "  - " << tool << "\n";
    }

    return 0;
}
