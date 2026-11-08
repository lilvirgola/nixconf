{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    pythonEnv = pkgs.python3.withPackages (p: [
      p.rich
      p.questionary
    ]);

    ninitScript = pkgs.writeScriptBin "ninit" ''
      #!${pythonEnv}/bin/python3
      """
      ninit — Automated Nix Flake Project Scaffolder & Template Manager
      """
      import os
      import sys
      import json
      import re
      import shutil
      import subprocess
      from rich.console import Console
      from rich.table import Table
      from rich.panel import Panel
      import questionary
      from questionary import Choice, Separator, Style

      console = Console()

      CUSTOM_STYLE = Style([
          ("qmark", "fg:#89dceb bold"),
          ("question", "bold"),
          ("answer", "fg:#a6e3a1 bold"),
          ("pointer", "fg:#f38ba8 bold"),
          ("highlighted", "fg:#89b4fa bold"),
          ("selected", "fg:#a6e3a1"),
          ("instruction", "fg:#6c7086 italic"),
          ("separator", "fg:#cba6f7 bold"),
      ])

      CATEGORY_ORDER = [
          "Systems & General Purpose",
          "Web & Runtimes",
          "Document & Typesetting",
          "Enterprise & Languages",
          "Security & CTF",
          "Other",
      ]

      def find_nixconf_dir():
          env_dir = os.environ.get("NIXCONF_DIR")
          if env_dir and os.path.isdir(os.path.join(env_dir, "templates")):
              return os.path.abspath(env_dir)

          home_nixconf = os.path.expanduser("~/nixconf")
          if os.path.isdir(os.path.join(home_nixconf, "templates")):
              return home_nixconf

          etc_nixos = "/etc/nixos"
          if os.path.isdir(os.path.join(etc_nixos, "templates")):
              return etc_nixos

          cwd = os.getcwd()
          if os.path.isdir(os.path.join(cwd, "templates")) and os.path.isfile(os.path.join(cwd, "flake.nix")):
              return cwd

          console.print("[bold red][!] Could not locate nixconf templates directory.[/bold red]")
          console.print("[dim]Set $NIXCONF_DIR or ensure ~/nixconf/templates exists.[/dim]")
          sys.exit(1)

      def parse_flake_nix(filepath):
          desc = ""
          aliases = []
          run_cmd = ""
          try:
              with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
                  for line in f:
                      if not desc:
                          m_desc = re.search(r'description\s*=\s*"([^"]+)"', line)
                          if m_desc:
                              desc = m_desc.group(1).strip()
                      m_alias = re.match(r"^#\s*Aliases:\s*(.*)", line.strip(), re.IGNORECASE)
                      if m_alias:
                          aliases.extend([a.strip() for a in m_alias.group(1).split(",") if a.strip()])
                      m_run = re.match(r"^#\s*Run:\s*(.*)", line.strip(), re.IGNORECASE)
                      if m_run:
                          run_cmd = m_run.group(1).strip()
          except Exception:
              pass
          return desc, aliases, run_cmd

      def load_templates(nixconf_dir):
          templates_dir = os.path.join(nixconf_dir, "templates")
          if not os.path.isdir(templates_dir):
              return []

          templates = []
          for entry in sorted(os.listdir(templates_dir)):
              entry_path = os.path.join(templates_dir, entry)
              if not os.path.isdir(entry_path):
                  continue
              if entry.startswith("."):
                  continue

              meta_file = os.path.join(entry_path, "template.json")
              if os.path.isfile(meta_file):
                  try:
                      with open(meta_file, "r", encoding="utf-8") as f:
                          data = json.load(f)
                      name = data.get("name", entry)
                      aliases = data.get("aliases", [])
                      desc = data.get("description", "")
                      cat = data.get("category", "Other")
                      run = data.get("run", "")
                  except Exception:
                      name = entry
                      aliases = []
                      desc = ""
                      cat = "Other"
                      run = ""
              else:
                  flake_path = os.path.join(entry_path, "flake.nix")
                  f_desc, f_aliases, f_run = parse_flake_nix(flake_path)
                  name = entry
                  aliases = f_aliases
                  desc = f_desc or f"{entry} template"
                  cat = "Other"
                  run = f_run

              templates.append({
                  "name": name,
                  "folder": entry,
                  "aliases": aliases,
                  "description": desc,
                  "category": cat,
                  "run": run,
                  "path": entry_path,
              })

          return templates

      def build_alias_map(templates):
          alias_map = {}
          for tmpl in templates:
              alias_map[tmpl["name"].lower()] = tmpl
              alias_map[tmpl["folder"].lower()] = tmpl
              for alias in tmpl["aliases"]:
                  alias_map[alias.lower()] = tmpl
          return alias_map

      def cmd_list(templates):
          table = Table(
              title="Available Project Templates",
              title_style="bold cyan",
              border_style="bright_blue",
              header_style="bold magenta",
          )
          table.add_column("Template", style="bold green", no_wrap=True)
          table.add_column("Aliases", style="yellow")
          table.add_column("Category", style="cyan")
          table.add_column("Description", style="white")
          table.add_column("Starter Command", style="dim green")

          grouped = {}
          for tmpl in templates:
              cat = tmpl.get("category", "Other")
              grouped.setdefault(cat, []).append(tmpl)

          for cat in CATEGORY_ORDER:
              if cat not in grouped:
                  continue
              for tmpl in grouped[cat]:
                  aliases_str = ", ".join(tmpl["aliases"]) if tmpl["aliases"] else "-"
                  table.add_row(
                      tmpl["name"],
                      aliases_str,
                      tmpl["category"],
                      tmpl["description"],
                      tmpl["run"] or "-",
                  )

          console.print()
          console.print(table)
          console.print(f"[dim]Total: {len(templates)} templates discovered in templates/ directory[/dim]\n")

      def cmd_help():
          console.print(Panel.fit(
              "[bold cyan]ninit — Nix Project Template Initializer[/bold cyan]\n\n"
              "[bold]Usage:[/bold]\n"
              "  ninit                     Interactive template picker and project setup\n"
              "  ninit <template> [dir]    Initialize specific template in target directory\n"
              "  ninit -l, --list          List all discovered templates and aliases in a table\n"
              "  ninit -h, --help          Show this help reference\n\n"
              "[bold]Examples:[/bold]\n"
              "  ninit rust my-crate       Initialize Rust template in ./my-crate\n"
              "  ninit py my-api           Initialize Python uv template in ./my-api\n"
              "  ninit ctf-pwn challenge1  Initialize CTF pwn harness in ./challenge1\n"
              "  ninit ctf-base            Initialize CTF base in current directory\n"
              "  ninit                     Browse templates interactively with search",
              border_style="cyan",
          ))

      def pick_target_directory(default_dir="."):
          cwd = os.getcwd()
          choices = [
              Choice(title=f"Current directory ({cwd})", value="."),
              Choice(title="Create a new directory", value="__new__"),
          ]
          try:
              selected = questionary.select(
                  "Target directory:",
                  choices=choices,
                  style=CUSTOM_STYLE,
                  use_indicator=True,
              ).ask()
          except KeyboardInterrupt:
              console.print("\n[red][!] Operation cancelled.[/red]")
              sys.exit(130)

          if not selected:
              sys.exit(0)

          if selected == "__new__":
              try:
                  new_dir = questionary.text(
                      "Enter new directory name:",
                      style=CUSTOM_STYLE,
                      validate=lambda val: True if val.strip() else "Directory name cannot be empty.",
                  ).ask()
              except KeyboardInterrupt:
                  console.print("\n[red][!] Operation cancelled.[/red]")
                  sys.exit(130)

              if not new_dir:
                  sys.exit(0)
              return new_dir.strip()

          return default_dir

      def init_project(nixconf_dir, template_info, target_dir):
          tmpl_name = template_info["name"]
          abs_target = os.path.abspath(target_dir) if target_dir != "." else os.getcwd()

          if target_dir != ".":
              os.makedirs(abs_target, exist_ok=True)
              os.chdir(abs_target)

          console.print(f"[bold cyan][+][/bold cyan] Initializing template '[bold green]{tmpl_name}[/bold green]' in [dim]{abs_target}[/dim]...")

          flake_ref = f"{nixconf_dir}#{tmpl_name}"
          proc = subprocess.run(
              ["nix", "flake", "init", "-t", flake_ref],
              stdout=subprocess.PIPE,
              stderr=subprocess.PIPE,
              text=True,
          )

          if proc.returncode != 0:
              console.print(f"[bold red][!] nix flake init failed:[/bold red]\n{proc.stderr.strip()}")
              sys.exit(proc.returncode)

          stray_meta = os.path.join(abs_target, "template.json")
          if os.path.isfile(stray_meta):
              try:
                  os.remove(stray_meta)
              except OSError:
                  pass

          git_check = subprocess.run(
              ["git", "rev-parse", "--is-inside-work-tree"],
              stdout=subprocess.DEVNULL,
              stderr=subprocess.DEVNULL,
          )
          if git_check.returncode != 0:
              subprocess.run(["git", "init", "-q"], check=False)
              console.print("[bold cyan][+][/bold cyan] Initialized empty Git repository.")

          gitignore_path = os.path.join(abs_target, ".gitignore")
          if not os.path.isfile(gitignore_path):
              with open(gitignore_path, "w", encoding="utf-8") as f:
                  f.write(".direnv/\nresult\nresult-*\n")
          else:
              try:
                  with open(gitignore_path, "r", encoding="utf-8", errors="ignore") as f:
                      content = f.read()
                  if ".direnv" not in content:
                      with open(gitignore_path, "a", encoding="utf-8") as f:
                          f.write("\n# Direnv\n.direnv/\n")
              except Exception:
                  pass

          subprocess.run(["git", "add", "-A"], check=False)
          console.print("[bold cyan][+][/bold cyan] Staged project files in Git.")

          if os.path.isfile(os.path.join(abs_target, ".envrc")) and shutil.which("direnv"):
              subprocess.run(["direnv", "allow"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
              console.print("[bold cyan][+][/bold cyan] Enabled direnv environment.")

          run_cmd = template_info.get("run", "")
          run_hint = f"\n[bold yellow]Starter command:[/] [bold green]{run_cmd}[/]" if run_cmd else ""

          console.print()
          console.print(Panel(
              f"[bold green]✔[/bold green] Project initialized successfully from template '[bold cyan]{tmpl_name}[/bold cyan]'!\n"
              f"[dim]Directory:[/] [white]{abs_target}[/white]"
              f"{run_hint}\n"
              f"[dim]Direnv loaded: automatic isolated dev environment active.[/dim]",
              title="[bold green]Ready[/bold green]",
              border_style="green",
              padding=(1, 2),
          ))

      def interactive_picker(templates):
          console.print()
          console.print(Panel(
              "[bold cyan]Nix Project Initializer[/bold cyan]\n"
              "[dim]Select a template to bootstrap a new workspace:[/dim]",
              border_style="cyan",
              padding=(0, 2),
          ))

          grouped = {}
          for tmpl in templates:
              cat = tmpl.get("category", "Other")
              grouped.setdefault(cat, []).append(tmpl)

          choices = []
          for cat in CATEGORY_ORDER:
              if cat not in grouped:
                  continue
              choices.append(Separator(f"─ {cat} ─"))
              for tmpl in grouped[cat]:
                  choices.append(Choice(
                      title=f"[{tmpl['name']:<12}] • {tmpl['description']}",
                      value=tmpl["name"],
                  ))

          try:
              selected = questionary.select(
                  "Choose template:",
                  choices=choices,
                  style=CUSTOM_STYLE,
                  use_indicator=True,
                  use_shortcuts=False,
              ).ask()
          except KeyboardInterrupt:
              console.print("\n[red][!] Operation cancelled.[/red]")
              sys.exit(130)

          if not selected:
              sys.exit(0)

          return selected

      def main():
          nixconf_dir = find_nixconf_dir()
          templates = load_templates(nixconf_dir)
          alias_map = build_alias_map(templates)

          args = sys.argv[1:]

          if not args:
              if not sys.stdin.isatty():
                  cmd_list(templates)
                  sys.exit(0)

              chosen_name = interactive_picker(templates)
              tmpl_info = alias_map.get(chosen_name.lower())
              if not tmpl_info:
                  console.print(f"[red][!] Template not found: {chosen_name}[/red]")
                  sys.exit(1)

              target_dir = pick_target_directory()
              init_project(nixconf_dir, tmpl_info, target_dir)
              sys.exit(0)

          first_arg = args[0]

          if first_arg in ("-h", "--help"):
              cmd_help()
              sys.exit(0)

          if first_arg in ("-l", "--list"):
              cmd_list(templates)
              sys.exit(0)

          tmpl_info = alias_map.get(first_arg.lower())
          if not tmpl_info:
              console.print(f"[bold red][!] Unknown template or alias:[/] '[yellow]{first_arg}[/yellow]'")
              console.print("[dim]Run 'ninit --list' to view all available templates and aliases.[/dim]")
              sys.exit(1)

          if len(args) > 1:
              target_dir = args[1]
          elif sys.stdin.isatty():
              target_dir = pick_target_directory()
          else:
              target_dir = "."

          init_project(nixconf_dir, tmpl_info, target_dir)

      if __name__ == "__main__":
          main()
    '';
  in {
    packages.ninit = pkgs.symlinkJoin {
      name = "ninit";
      paths = [ninitScript];
      buildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/ninit \
          --prefix PATH : ${pkgs.lib.makeBinPath (with pkgs; [git nix direnv coreutils])}
      '';
    };
  };
}
