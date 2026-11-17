{...}: {
  perSystem = {pkgs, ...}: let
    runtimePath = pkgs.lib.makeBinPath (with pkgs; [
      coreutils
      gnugrep
      jq
      openssh
      rbw
      bitwarden-cli
    ]);

    sshVaultLoad = pkgs.writeShellScriptBin "ssh-vault-load" ''
      export PATH="${runtimePath}:$PATH"
      if [[ "''${1:-}" == "-h" || "''${1:-}" == "--help" ]]; then
        echo "Usage: ssh-vault-load [KEY_NAME]"
        echo
        echo "Load an SSH private key from Bitwarden / Vaultwarden into ssh-agent."
        echo
        echo "Arguments:"
        echo "  KEY_NAME    Name of the vault item (default: id_ed25519)"
        echo
        echo "Options:"
        echo "  -l, --list  List all items in the vault"
        echo "  -h, --help  Show this help message"
        exit 0
      fi

      if [[ "''${1:-}" == "-l" || "''${1:-}" == "--list" ]]; then
        exec ssh-vault-list
      fi

      key_name="''${1:-id_ed25519}"
      key_data=""

      if command -v rbw >/dev/null 2>&1; then
        if ! rbw unlocked >/dev/null 2>&1; then
          echo "[*] Unlocking Bitwarden vault..."
          rbw unlock || exit 1
        fi
        key_data=$(rbw get --field private-key "$key_name" 2>/dev/null || true)
        if [[ -z "$key_data" ]]; then
          key_data=$(rbw get --field ssh-key "$key_name" 2>/dev/null || true)
        fi
        if [[ -z "$key_data" ]]; then
          key_data=$(rbw notes "$key_name" 2>/dev/null || true)
        fi
      fi

      if [[ -z "$key_data" ]] && command -v bw >/dev/null 2>&1; then
        key_data=$(bw get item "$key_name" 2>/dev/null | jq -r '.sshKey.privateKey // .fields[]? | select(.name=="private-key" or .name=="ssh-key").value // .notes' 2>/dev/null || true)
      fi

      if [[ -z "$key_data" ]]; then
        echo "[!] Could not find private key for '$key_name' in Bitwarden vault."
        echo "    Make sure the key is in field 'private-key', 'ssh-key', Notes, or an official SSH Key item."
        exit 1
      fi

      echo "$key_data" | ssh-add -
      echo "[+] SSH key '$key_name' loaded into ssh-agent successfully!"
      ssh-add -l
    '';

    sshVaultList = pkgs.writeShellScriptBin "ssh-vault-list" ''
      export PATH="${runtimePath}:$PATH"
      if command -v rbw >/dev/null 2>&1 && rbw unlocked >/dev/null 2>&1; then
        echo "[*] Items in Bitwarden vault (rbw):"
        rbw list
      elif command -v bw >/dev/null 2>&1; then
        echo "[*] Items in Bitwarden vault (bw):"
        bw list items 2>/dev/null | jq -r '.[].name' 2>/dev/null
      else
        echo "[!] Please unlock rbw ('rbw unlock') or bw ('bw unlock') first."
        exit 1
      fi
    '';

    sshVaultAdd = pkgs.writeShellScriptBin "ssh-vault-add" ''
      export PATH="${runtimePath}:$PATH"
      key_path=""
      key_name=""
      force=false
      gen_new=false
      del_local=false

      if [[ "''${1:-}" == "-h" || "''${1:-}" == "--help" ]]; then
        echo "Usage: ssh-vault-add [OPTIONS] [KEY_PATH_OR_NAME] [KEY_NAME]"
        echo
        echo "Save an SSH private/public key pair into Bitwarden / Vaultwarden."
        echo
        echo "Options:"
        echo "  -f, --force        Overwrite item in vault if it already exists"
        echo "  -g, --generate     Generate a new Ed25519 key if the specified file does not exist"
        echo "  -d, --delete-local Remove unencrypted private key from disk after successful upload"
        echo "  -h, --help         Show this help message"
        exit 0
      fi

      while [[ $# -gt 0 ]]; do
        case "$1" in
          -f|--force) force=true; shift ;;
          -g|--generate) gen_new=true; shift ;;
          -d|--delete-local) del_local=true; shift ;;
          -*) echo "[!] Unknown option: $1"; exit 1 ;;
          *)
            if [[ -z "$key_path" ]]; then
              key_path="$1"
            elif [[ -z "$key_name" ]]; then
              key_name="$1"
            fi
            shift
            ;;
        esac
      done

      if [[ -z "$key_path" ]]; then
        if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
          key_path="$HOME/.ssh/id_ed25519"
          key_name="id_ed25519"
        elif [[ -f "$HOME/.ssh/id_rsa" ]]; then
          key_path="$HOME/.ssh/id_rsa"
          key_name="id_rsa"
        else
          key_path="$HOME/.ssh/id_ed25519"
          key_name="id_ed25519"
        fi
      else
        key_path="''${key_path/#\~/$HOME}"
        if [[ ! -f "$key_path" && -f "$HOME/.ssh/$key_path" ]]; then
          [[ -z "$key_name" ]] && key_name="$key_path"
          key_path="$HOME/.ssh/$key_path"
        fi
        [[ -z "$key_name" ]] && key_name="$(basename "$key_path")"
      fi

      if [[ ! -f "$key_path" ]]; then
        if [[ "$gen_new" == true ]]; then
          echo "[*] Generating new Ed25519 key at '$key_path'..."
          mkdir -p "$(dirname "$key_path")"
          ssh-keygen -t ed25519 -f "$key_path" -C "$key_name" || exit 1
        else
          echo -n "[?] Key '$key_path' not found. Generate a new Ed25519 key? [y/N]: "
          read -r answer
          if [[ "$answer" =~ ^[Yy]$ ]]; then
            mkdir -p "$(dirname "$key_path")"
            ssh-keygen -t ed25519 -f "$key_path" -C "$key_name" || exit 1
          else
            echo "[!] Aborted: key file not found."
            exit 1
          fi
        fi
      fi

      if ! grep -q "PRIVATE KEY" "$key_path" 2>/dev/null; then
        echo "[!] Error: '$key_path' does not appear to be a valid private key."
        exit 1
      fi

      priv_key="$(cat "$key_path")"
      if [[ -f "''${key_path}.pub" ]]; then
        pub_key="$(cat "''${key_path}.pub")"
      else
        pub_key="$(ssh-keygen -y -f "$key_path" 2>/dev/null || true)"
      fi

      saved=false
      if command -v bw >/dev/null 2>&1; then
        bw_status="$(bw status 2>/dev/null | jq -r '.status // empty' 2>/dev/null || true)"
        if [[ "$bw_status" == "locked" ]]; then
          echo "[*] Vault is locked. Enter master password to unlock:"
          session="$(bw unlock --raw)" || true
          if [[ -n "$session" ]]; then
            export BW_SESSION="$session"
            bw_status="unlocked"
          fi
        fi

        if [[ "$bw_status" == "unlocked" ]]; then
          existing_id="$(bw list items --search "$key_name" ''${BW_SESSION:+--session "$BW_SESSION"} 2>/dev/null | jq -r --arg n "$key_name" '.[] | select(.name==$n) | .id' 2>/dev/null | head -n1 || true)"
          if [[ -n "$existing_id" && "$existing_id" != "null" && "$force" != true ]]; then
            echo -n "[?] Item '$key_name' already exists in vault (ID: $existing_id). Overwrite? [y/N]: "
            read -r ans
            [[ "$ans" =~ ^[Yy]$ ]] || exit 1
          fi

          item_json="$(jq -n \
            --arg name "$key_name" \
            --arg priv "$priv_key" \
            --arg pub "$pub_key" \
            '{
              type: 2,
              name: $name,
              notes: $priv,
              fields: [
                { name: "private-key", value: $priv, type: 1 },
                { name: "public-key", value: $pub, type: 0 }
              ],
              secureNote: { type: 0 }
            }')"

          if [[ -n "$existing_id" && "$existing_id" != "null" ]]; then
            edit_json="$(printf '%s' "$item_json" | jq --arg id "$existing_id" '.id = $id')"
            edit_encoded="$(printf '%s' "$edit_json" | base64 | tr -d '\r\n')"
            bw edit item "$existing_id" "$edit_encoded" ''${BW_SESSION:+--session "$BW_SESSION"} >/dev/null && saved=true
          else
            encoded="$(printf '%s' "$item_json" | base64 | tr -d '\r\n')"
            bw create item "$encoded" ''${BW_SESSION:+--session "$BW_SESSION"} >/dev/null && saved=true
          fi
          [[ "$saved" == true ]] && bw sync >/dev/null 2>&1 || true
        fi
      fi

      if [[ "$saved" != true ]] && command -v rbw >/dev/null 2>&1; then
        if ! rbw unlocked >/dev/null 2>&1; then
          rbw unlock || true
        fi
        if rbw unlocked >/dev/null 2>&1; then
          existing_rbw="$(rbw list 2>/dev/null | grep -E "^''${key_name}$" || true)"
          if [[ -n "$existing_rbw" && "$force" != true ]]; then
            echo -n "[?] Item '$key_name' already exists in rbw. Overwrite? [y/N]: "
            read -r ans
            [[ "$ans" =~ ^[Yy]$ ]] || exit 1
            rbw remove "$key_name" 2>/dev/null || true
          fi
          tmp_editor="$(mktemp)"
          chmod +x "$tmp_editor"
          printf '#!/usr/bin/env bash\nprintf "\\n%%s\\n" "$SSH_VAULT_KEY_DATA" > "$1"\n' > "$tmp_editor"
          SSH_VAULT_KEY_DATA="$priv_key" EDITOR="$tmp_editor" rbw add "$key_name" >/dev/null 2>&1 && saved=true
          rm -f "$tmp_editor"
          [[ "$saved" == true ]] && rbw sync >/dev/null 2>&1 || true
        fi
      fi

      if [[ "$saved" == true ]]; then
        echo "[+] SSH key '$key_name' saved to Bitwarden / Vaultwarden!"
        [[ -n "$pub_key" ]] && echo "    Public key: $pub_key"
        if [[ "$del_local" == true ]]; then
          rm -f "$key_path"
          echo "[*] Local private key '$key_path' removed."
        fi
      else
        echo "[!] Could not save key to Bitwarden. Please ensure 'bw' or 'rbw' is logged in."
        exit 1
      fi
    '';
  in {
    packages.ssh-vault = pkgs.symlinkJoin {
      name = "ssh-vault";
      paths = [sshVaultLoad sshVaultList sshVaultAdd];
    };
  };
}
