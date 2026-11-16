{...}: {
  perSystem = {
    pkgs,
    lib,
    self',
    ...
  }: let
    kb = import ../wrappedPrograms/_keybindings.nix {inherit pkgs lib self';};
    quotedItems = builtins.concatStringsSep "\n" (map (i: "          " + lib.escapeShellArg i) kb.keyhintsItems);
    rofiTheme = pkgs.writeText "keyhints-rofi.rasi" ''
      * {
          font: "JetBrains Mono Nerd Font 10.5";
          bg: rgba(30, 30, 46, 0.94);
          bg-alt: rgba(49, 50, 68, 0.85);
          fg: #cdd6f4;
          fg-dim: #a6adc8;
          accent: #89b4fa;
          urgent: #f38ba8;
          selected: #45475a;
          border-col: #89b4fa;

          background-color: transparent;
          text-color: @fg;
          margin: 0;
          padding: 0;
      }

      window {
          transparency: "real";
          background-color: @bg;
          border: 2px solid;
          border-color: @border-col;
          border-radius: 12px;
          width: 820px;
          padding: 16px;
      }

      mainbox {
          children: [ inputbar, message, listview ];
          spacing: 12px;
      }

      inputbar {
          background-color: @bg-alt;
          border-radius: 8px;
          padding: 10px 14px;
          children: [ prompt, entry ];
          spacing: 10px;
      }

      prompt {
          text-color: @accent;
          font: "JetBrains Mono Nerd Font Bold 11";
      }

      entry {
          text-color: @fg;
          placeholder: "Type to filter keybindings... (Esc to close)";
          placeholder-color: @fg-dim;
      }

      message {
          background-color: @bg-alt;
          border-radius: 8px;
          padding: 8px 12px;
      }

      textbox {
          text-color: @fg-dim;
      }

      listview {
          lines: 15;
          columns: 1;
          spacing: 4px;
          scrollbar: false;
          fixed-height: true;
      }

      element {
          padding: 6px 12px;
          border-radius: 6px;
          children: [ element-text ];
      }

      element selected {
          background-color: @selected;
          text-color: @accent;
      }

      element-text {
          text-color: inherit;
          highlight: bold #f9e2af;
      }
    '';

    keyhintsScript = pkgs.writeShellApplication {
      name = "keyhints";
      runtimeInputs = with pkgs; [
        rofi
        yad
        procps
        coreutils
        libnotify
        grim
        slurp
        swappy
      ];
      text = ''
                # If rofi is already running, kill it to provide toggle behavior
                if pgrep -x "rofi" >/dev/null 2>&1; then
                  pkill -x "rofi"
                  exit 0
                fi

                SHOW_TABLE=0
                if [ "''${1:-}" = "-t" ] || [ "''${1:-}" = "--table" ] || [ "''${1:-}" = "table" ]; then
                  SHOW_TABLE=1
                fi

                # Definition of all enabled keybindings (synced with mangowm via _keybindings.nix)
                # Format: Category | Keybind | Description | Action
                ITEMS=(
        ${quotedItems}
                )

                show_yad_table() {
                  YAD_ARGS=(
                    "--title=Keybindings Cheatsheet"
                    "--window-icon=preferences-desktop-keyboard-shortcuts"
                    "--width=860"
                    "--height=640"
                    "--center"
                    "--list"
                    "--grid-lines=both"
                    "--no-buttons"
                    "--column=Category:TEXT"
                    "--column=Shortcut:TEXT"
                    "--column=Description:TEXT"
                  )
                  for item in "''${ITEMS[@]}"; do
                    IFS='|' read -r cat key desc _ <<< "$item"
                    YAD_ARGS+=("$cat" "$key" "$desc")
                  done
                  yad "''${YAD_ARGS[@]}" >/dev/null 2>&1 &
                }

                if [ "$SHOW_TABLE" -eq 1 ]; then
                  show_yad_table
                  exit 0
                fi

                # Generate Rofi list with markup
                ROFI_INPUT="📋  View Full Table Cheatsheet (YAD)  ──  Open persistent graphical window\n"
                for item in "''${ITEMS[@]}"; do
                  IFS='|' read -r cat key desc _ <<< "$item"
                  ROFI_INPUT+="$(printf "<span color='#89b4fa'><b>%-30s</b></span>  <span color='#cdd6f4'>%-38s</span>  <span color='#6c7086'>[%s]</span>\n" "$key" "$desc" "$cat")\n"
                done

                SELECTED=$(printf '%b' "$ROFI_INPUT" | rofi \
                  -dmenu \
                  -i \
                  -markup-rows \
                  -p "⌨ Shortcuts" \
                  -mesg "<b>SUPER + H</b> • Type to filter • Enter runs action • Esc closes" \
                  -theme "${rofiTheme}" \
                  || true)

                if [ -z "$SELECTED" ]; then
                  exit 0
                fi

                # Handle selected action
                if [[ "$SELECTED" == *"View Full Table Cheatsheet"* ]]; then
                  show_yad_table
                  exit 0
                fi

                # Match action from ITEMS
                for item in "''${ITEMS[@]}"; do
                  IFS='|' read -r _ key desc action <<< "$item"
                  if [[ "$SELECTED" == *"$key"* ]]; then
                    case "$action" in
                      kitty)
                        kitty &
                        ;;
                      browser)
                        firefox &
                        ;;
                      files)
                        thunar &
                        ;;
                      launcher)
                        noctalia msg panel-toggle launcher || true
                        ;;
                      clipboard)
                        noctalia msg panel-toggle clipboard || true
                        ;;
                      control-center)
                        noctalia msg panel-toggle control-center || true
                        ;;
                      session)
                        noctalia msg panel-toggle session || true
                        ;;
                      lock)
                        noctalia msg session lock || true
                        ;;
                      screenshot-area)
                        grim -g "$(slurp)" - | swappy -f - &
                        ;;
                      screenshot-full)
                        mkdir -p "$HOME/Pictures/Screenshots"
                        grim "$HOME/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png" &
                        notify-send "Screenshot" "Saved full screen screenshot to ~/Pictures/Screenshots/"
                        ;;
                      screenshot-area-save)
                        mkdir -p "$HOME/Pictures/Screenshots"
                        grim -g "$(slurp)" "$HOME/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png" &
                        notify-send "Screenshot" "Saved area screenshot to ~/Pictures/Screenshots/"
                        ;;
                      keyhints)
                        show_yad_table
                        ;;
                      *)
                        notify-send "Keybinding" "$key: $desc" || true
                        ;;
                    esac
                    break
                  fi
                done
      '';
    };
  in {
    packages.keyhints = keyhintsScript;
  };
}
