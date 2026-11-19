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
        type = lib.types.nullOr lib.types.str;
        default = "nixos";
        description = "Initial default password for the primary user account (set null when using hashedPassword or SSH keys only).";
      };

      sshAuthorizedKeys = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKXpAYYAl+vHTkska3A+8YQG7SWLjw8UUSRNnwS0RfNo virgola@virgola-laptop"
        ];
        description = "SSH public keys authorized for the primary user account.";
      };

      enableCuda = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether CUDA acceleration is available on this host (enabled automatically by nvidia module).";
      };

      git = {
        userName = lib.mkOption {
          type = lib.types.str;
          default = "virgola";
          description = "Git author/committer name.";
        };

        userEmail = lib.mkOption {
          type = lib.types.str;
          default = "alessandro.debiasi@protonmail.com";
          description = "Git author/committer email.";
        };

        defaultBranch = lib.mkOption {
          type = lib.types.str;
          default = "main";
          description = "Default branch name for new Git repositories.";
        };
      };

      apps = {
        browser = lib.mkOption {
          type = lib.types.str;
          default = "firefox";
          description = "Default $BROWSER command.";
        };

        browserDesktop = lib.mkOption {
          type = lib.types.str;
          default = "firefox.desktop";
          description = "Desktop entry for HTTP/HTTPS/HTML.";
        };

        editor = lib.mkOption {
          type = lib.types.str;
          default = "nvim";
          description = "Default $EDITOR command.";
        };

        editorDesktop = lib.mkOption {
          type = lib.types.str;
          default = "antigravity-ide.desktop";
          description = "Desktop entry for plain text and source files.";
        };

        terminal = lib.mkOption {
          type = lib.types.str;
          default = "kitty";
          description = "Default $TERMINAL and XFCE TerminalEmulator helper.";
        };

        fileManagerDesktop = lib.mkOption {
          type = lib.types.str;
          default = "thunar.desktop";
          description = "Desktop entry for directories.";
        };

        pdfViewerDesktop = lib.mkOption {
          type = lib.types.str;
          default = "org.pwmt.zathura.desktop";
          description = "Desktop entry for PDF/DjVu/PostScript documents.";
        };

        imageViewerDesktop = lib.mkOption {
          type = lib.types.str;
          default = "imv.desktop";
          description = "Desktop entry for images.";
        };

        mediaPlayerDesktop = lib.mkOption {
          type = lib.types.str;
          default = "mpv.desktop";
          description = "Desktop entry for audio and video files.";
        };

        calendarDesktop = lib.mkOption {
          type = lib.types.str;
          default = "org.gnome.Calendar.desktop";
          description = "Desktop entry for calendar events.";
        };
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

      theme = {
        colorScheme = lib.mkOption {
          type = lib.types.enum ["dark" "light" "default"];
          default = "dark";
          description = "Global color scheme preference for XDG desktop portals, Qt, and GTK applications.";
        };

        gtkTheme = lib.mkOption {
          type = lib.types.str;
          default = "adw-gtk3-dark";
          description = "GTK 3/4 application theme name.";
        };

        iconTheme = lib.mkOption {
          type = lib.types.str;
          default = "Papirus-Dark";
          description = "System-wide icon theme.";
        };

        cursorTheme = lib.mkOption {
          type = lib.types.str;
          default = "Bibata-Modern-Classic";
          description = "System-wide cursor theme.";
        };

        cursorSize = lib.mkOption {
          type = lib.types.int;
          default = 24;
          description = "Default cursor size.";
        };
      };
    };
  };
}
