# Centralized User Identity & System Regional Settings
# This file serves as the single source of truth for the primary user account,
# timezone, locale, and keyboard configuration. Change values here to customize
# your installation across all hosts, sudoers rules, display managers, and shells.
{
  flake.nixosModules.settings = {lib, ...}: {
    options.custom = {
      username = lib.mkOption {
        type = lib.types.str;
        default = "virgola";
        description = "Primary user login name across system configurations, groups, sudoers, and desktop sessions.";
      };

      userDescription = lib.mkOption {
        type = lib.types.str;
        default = "Alessandro";
        description = "Full name / GECOS description for the primary user.";
      };

      initialPassword = lib.mkOption {
        type = lib.types.str;
        default = "nixos";
        description = "Initial default password for the primary user account.";
      };

      timezone = lib.mkOption {
        type = lib.types.str;
        default = "Europe/Rome";
        description = "System timezone.";
      };

      locale = lib.mkOption {
        type = lib.types.str;
        default = "en_US.UTF-8";
        description = "Primary system locale.";
      };

      extraLocale = lib.mkOption {
        type = lib.types.str;
        default = "it_IT.UTF-8";
        description = "Secondary locale for date/time, measurement, and currency formatting.";
      };

      keyboardLayout = lib.mkOption {
        type = lib.types.str;
        default = "it";
        description = "X11 and Wayland keyboard layout.";
      };

      consoleKeyMap = lib.mkOption {
        type = lib.types.str;
        default = "it2";
        description = "Linux console TTY keymap.";
      };
    };
  };
}
