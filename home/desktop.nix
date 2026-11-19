{
  pkgs,
  osConfig,
  ...
}: {
  gtk = {
    enable = true;
    theme.name = osConfig.custom.theme.gtkTheme;
    iconTheme.name = osConfig.custom.theme.iconTheme;
    cursorTheme = {
      name = osConfig.custom.theme.cursorTheme;
      size = osConfig.custom.theme.cursorSize;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = osConfig.custom.theme.colorScheme == "dark";
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = osConfig.custom.theme.colorScheme == "dark";
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme =
        if osConfig.custom.theme.colorScheme == "dark"
        then "prefer-dark"
        else "default";
    };
  };

  home.pointerCursor = {
    enable = true;
    name = osConfig.custom.theme.cursorTheme;
    package = pkgs.bibata-cursors;
    size = osConfig.custom.theme.cursorSize;
    gtk.enable = true;
    x11.enable = true;
  };

  xdg.configFile = {
    "zathura/zathurarc".text = ''
      set synctex true
      set synctex-editor-command "antigravity --goto %{input}:%{line}"
      set selection-clipboard clipboard
    '';

    "xfce4/helpers.rc".text = ''
      TerminalEmulator=${osConfig.custom.apps.terminal}
      TerminalEmulatorDismissed=true
    '';
    # apparently exo is beeing deprecated, so this should work without deps
    "Thunar/uca.xml".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <actions>
      <action>
        <icon>utilities-terminal</icon>
        <name>Open Terminal Here</name>
        <submenu></submenu>
        <unique-id>1793734689284411-1</unique-id>
        <command>${osConfig.custom.apps.terminal} --working-directory %f</command>
        <description>Open terminal in selected directory</description>
        <range></range>
        <patterns>*</patterns>
        <startup-notify/>
        <directories/>
      </action>
      </actions>
    '';

    "kitty/ssh.conf".source = ../assets/kitty/ssh.conf;
    "kitty/remote_aliases.sh".source = ../assets/kitty/remote_aliases.sh;
    "kitty/templates" = {
      source = ../assets/kitty/templates;
      recursive = true;
    };
  };

  home.sessionVariables = {
    BROWSER = osConfig.custom.apps.browser;
    EDITOR = osConfig.custom.apps.editor;
    TERMINAL = osConfig.custom.apps.terminal;
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Web
      "text/html" = [osConfig.custom.apps.browserDesktop];
      "application/xhtml+xml" = [osConfig.custom.apps.browserDesktop];
      "x-scheme-handler/http" = [osConfig.custom.apps.browserDesktop];
      "x-scheme-handler/https" = [osConfig.custom.apps.browserDesktop];
      "x-scheme-handler/about" = [osConfig.custom.apps.browserDesktop];
      "x-scheme-handler/unknown" = [osConfig.custom.apps.browserDesktop];

      # File manager
      "inode/directory" = [osConfig.custom.apps.fileManagerDesktop];

      # Documents & PDFs
      "application/pdf" = [osConfig.custom.apps.pdfViewerDesktop];
      "application/x-pdf" = [osConfig.custom.apps.pdfViewerDesktop];
      "application/postscript" = [osConfig.custom.apps.pdfViewerDesktop];
      "image/vnd.djvu" = [osConfig.custom.apps.pdfViewerDesktop];

      # Images
      "image/png" = [osConfig.custom.apps.imageViewerDesktop];
      "image/jpeg" = [osConfig.custom.apps.imageViewerDesktop];
      "image/webp" = [osConfig.custom.apps.imageViewerDesktop];
      "image/gif" = [osConfig.custom.apps.imageViewerDesktop];
      "image/bmp" = [osConfig.custom.apps.imageViewerDesktop];
      "image/tiff" = [osConfig.custom.apps.imageViewerDesktop];
      "image/svg+xml" = [osConfig.custom.apps.imageViewerDesktop];

      # Video & Audio
      "video/mp4" = [osConfig.custom.apps.mediaPlayerDesktop];
      "video/x-matroska" = [osConfig.custom.apps.mediaPlayerDesktop];
      "video/webm" = [osConfig.custom.apps.mediaPlayerDesktop];
      "video/quicktime" = [osConfig.custom.apps.mediaPlayerDesktop];
      "video/x-msvideo" = [osConfig.custom.apps.mediaPlayerDesktop];
      "audio/mpeg" = [osConfig.custom.apps.mediaPlayerDesktop];
      "audio/flac" = [osConfig.custom.apps.mediaPlayerDesktop];
      "audio/ogg" = [osConfig.custom.apps.mediaPlayerDesktop];
      "audio/wav" = [osConfig.custom.apps.mediaPlayerDesktop];
      "audio/mp4" = [osConfig.custom.apps.mediaPlayerDesktop];
      "audio/x-opus+ogg" = [osConfig.custom.apps.mediaPlayerDesktop];

      # Text & Code
      "text/plain" = [osConfig.custom.apps.editorDesktop];
      "text/markdown" = [osConfig.custom.apps.editorDesktop];
      "text/x-python" = [osConfig.custom.apps.editorDesktop];
      "text/x-csrc" = [osConfig.custom.apps.editorDesktop];
      "text/x-c++src" = [osConfig.custom.apps.editorDesktop];
      "text/x-shellscript" = [osConfig.custom.apps.editorDesktop];
      "application/json" = [osConfig.custom.apps.editorDesktop];
      "application/x-yaml" = [osConfig.custom.apps.editorDesktop];
      "application/toml" = [osConfig.custom.apps.editorDesktop];
      "application/xml" = [osConfig.custom.apps.editorDesktop];

      # Calendar
      "text/calendar" = [osConfig.custom.apps.calendarDesktop];
    };
  };
}
