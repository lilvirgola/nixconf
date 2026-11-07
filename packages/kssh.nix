{...}: {
  perSystem = {pkgs, ...}: let
    pythonEnv = pkgs.python3.withPackages (p: [
      p.rich
      p.questionary
    ]);

    ksshScript = pkgs.writeScriptBin "kssh" ''
      #!${pythonEnv}/bin/python3
      """
      kssh — Kitty SSH Kitten Interactive Connection & Profile Manager
      """
      import os
      import sys
      import re
      import fnmatch
      import subprocess
      import datetime
      from rich.console import Console
      from rich.table import Table
      from rich.panel import Panel
      import questionary
      from questionary import Choice, Style

      console = Console()

      KITTY_DIR = os.path.expanduser("~/.config/kitty")
      HOSTS_CONF = os.path.join(KITTY_DIR, "ssh_hosts.conf")
      TEMPLATES_DIR = os.path.join(KITTY_DIR, "templates")

      CUSTOM_STYLE = Style([
          ("qmark", "fg:#89dceb bold"),
          ("question", "bold"),
          ("answer", "fg:#a6e3a1 bold"),
          ("pointer", "fg:#f38ba8 bold"),
          ("highlighted", "fg:#89b4fa bold"),
          ("selected", "fg:#a6e3a1"),
          ("instruction", "fg:#6c7086 italic"),
      ])

      def ensure_dirs():
          os.makedirs(KITTY_DIR, exist_ok=True)
          os.makedirs(TEMPLATES_DIR, exist_ok=True)
          if not os.path.exists(HOSTS_CONF):
              with open(HOSTS_CONF, "w", encoding="utf-8") as f:
                  f.write("# Dynamic SSH endpoint configurations (managed by kssh)\n")

      def parse_description(filepath):
          try:
              with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
                  for line in f:
                      m = re.match(r"^#\s*[Dd]escription:\s*(.*)", line.strip())
                      if m:
                          return m.group(1).strip()
          except Exception:
              pass
          return None

      def load_templates():
          ensure_dirs()
          preferred = ["server", "embedded", "dev-box", "minimal"]
          templates = []
          seen = set()

          for name in preferred:
              path = os.path.join(TEMPLATES_DIR, f"{name}.conf")
              if os.path.isfile(path):
                  desc = parse_description(path) or f"{name.capitalize()} profile"
                  templates.append({"name": name, "path": path, "desc": desc})
                  seen.add(name)

          if os.path.isdir(TEMPLATES_DIR):
              for fname in sorted(os.listdir(TEMPLATES_DIR)):
                  if fname.endswith(".conf"):
                      bname = fname[:-5]
                      if bname not in seen:
                          path = os.path.join(TEMPLATES_DIR, fname)
                          desc = parse_description(path) or f"{bname.capitalize()} profile"
                          templates.append({"name": bname, "path": path, "desc": desc})
                          seen.add(bname)

          if not templates:
              templates = [
                  {"name": "server", "path": "", "desc": "Standard Linux Server / VM (remote kitten, aliases, truecolor)"},
                  {"name": "embedded", "path": "", "desc": "Embedded Device / Router (minimal, terminfo only, no kitten)"},
                  {"name": "dev-box", "path": "", "desc": "Development Workstation / VM (remote kitten, tools, remote control)"},
                  {"name": "minimal", "path": "", "desc": "Plain / Vanilla SSH (terminfo & shell integration only)"},
              ]
          return templates

      def parse_configured_hosts():
          ensure_dirs()
          hosts = []
          current = None
          try:
              with open(HOSTS_CONF, "r", encoding="utf-8", errors="ignore") as f:
                  for line in f:
                      line_str = line.strip()
                      prof_m = re.match(r"^#\s*\[profile:\s*([^\]]+)\]\s*(.*)", line_str)
                      if prof_m:
                          current = {
                              "profile": prof_m.group(1).strip(),
                              "info": prof_m.group(2).strip(),
                              "hostname_patterns": "",
                              "include": ""
                          }
                          hosts.append(current)
                          continue
                      if current and line_str.startswith("hostname "):
                          current["hostname_patterns"] = line_str[9:].strip()
                      if current and line_str.startswith("include "):
                          current["include"] = line_str[8:].strip()
          except Exception:
              pass
          return hosts

      def is_configured(candidates):
          ensure_dirs()
          try:
              with open(HOSTS_CONF, "r", encoding="utf-8", errors="ignore") as f:
                  for line in f:
                      line_str = line.strip()
                      if line_str.startswith("hostname "):
                          patterns = line_str[9:].split()
                          for cand in candidates:
                              for pat in patterns:
                                  if fnmatch.fnmatchcase(cand, pat):
                                      return True
                                  if pat.startswith("*@") and cand == pat[2:]:
                                      return True
                                  if cand.endswith("@" + pat):
                                      return True
          except Exception:
              pass
          return False

      def resolve_canonical_host(target):
          try:
              proc = subprocess.run(
                  ["ssh", "-G", target],
                  stdout=subprocess.PIPE,
                  stderr=subprocess.DEVNULL,
                  text=True,
                  timeout=2
              )
              if proc.returncode == 0:
                  for line in proc.stdout.splitlines():
                      if line.startswith("hostname "):
                          return line.split()[1]
          except Exception:
              pass
          return None

      def parse_target(args):
          skip = False
          opt_with_arg = {
              "-b", "-c", "-D", "-E", "-e", "-F", "-I", "-i", "-J", "-L",
              "-l", "-m", "-O", "-o", "-p", "-Q", "-R", "-S", "-W", "-w", "-B", "--kitten"
          }
          for arg in args:
              if skip:
                  skip = False
                  continue
              if arg in opt_with_arg:
                  skip = True
                  continue
              if any(arg.startswith(prefix) for prefix in opt_with_arg if len(prefix) == 2 and arg != prefix):
                  continue
              if arg.startswith("-"):
                  continue
              return arg
          return None

      def save_profile(tmpl_name, host, resolved_host):
          ensure_dirs()
          now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
          patterns = [host, f"*@{host}"]
          if resolved_host and resolved_host != host:
              patterns.extend([resolved_host, f"*@{resolved_host}"])
          pattern_str = " ".join(patterns)

          entry = f"\n# [profile: {tmpl_name}] {host} ({now})\nhostname {pattern_str}\ninclude templates/{tmpl_name}.conf\n"
          with open(HOSTS_CONF, "a", encoding="utf-8") as f:
              f.write(entry)

      def cmd_list():
          hosts = parse_configured_hosts()
          if not hosts:
              console.print(Panel("[dim]No SSH endpoints configured yet. Connect to a host with 's <host>' to set one up.[/dim]", title="Configured Kitty SSH Endpoints", border_style="cyan"))
              return
          table = Table(title="Configured Kitty SSH Endpoints", title_style="bold cyan", border_style="bright_blue", header_style="bold magenta")
          table.add_column("Endpoint / Info", style="bold yellow")
          table.add_column("Profile Template", style="bold green")
          table.add_column("Patterns", style="dim white")
          table.add_column("Include Target", style="cyan")

          for h in hosts:
              table.add_row(
                  h["info"] or "Unknown",
                  h["profile"],
                  h["hostname_patterns"],
                  h["include"]
              )
          console.print(table)
          console.print(f"[dim]Stored in: {HOSTS_CONF}[/dim]\n")

      def cmd_templates():
          templates = load_templates()
          table = Table(title="Available Connection Templates", title_style="bold cyan", border_style="bright_blue", header_style="bold magenta")
          table.add_column("#", style="dim", justify="right")
          table.add_column("Template", style="bold green")
          table.add_column("Description", style="white")
          table.add_column("Path", style="dim")

          for idx, tmpl in enumerate(templates, 1):
              tag = " [bold cyan][default][/]" if idx == 1 else ""
              table.add_row(str(idx), f"{tmpl['name']}{tag}", tmpl["desc"], tmpl["path"])
          console.print(table)
          console.print(f"[dim]Templates directory: {TEMPLATES_DIR}[/dim]\n")

      def cmd_edit():
          ensure_dirs()
          editor = os.environ.get("EDITOR", "vim")
          os.execvp(editor, [editor, HOSTS_CONF])

      def cmd_edit_template(name):
          ensure_dirs()
          if not name:
              console.print("[red][!] Please specify a template name: kssh --edit-template <NAME>[/red]")
              cmd_templates()
              sys.exit(1)
          if not name.endswith(".conf"):
              name += ".conf"
          path = os.path.join(TEMPLATES_DIR, name)
          if not os.path.exists(path):
              with open(path, "w", encoding="utf-8") as f:
                  f.write(f"# Description: Custom {name[:-5]} connection profile\nremote_kitty if-needed\nshell_integration inherited\n")
          editor = os.environ.get("EDITOR", "vim")
          os.execvp(editor, [editor, path])

      def cmd_remove(host_to_remove):
          ensure_dirs()
          if not host_to_remove:
              console.print("[red][!] Please specify a host to remove: kssh --remove <HOST>[/red]")
              sys.exit(1)
          lines = []
          removed = False
          skip_block = False

          with open(HOSTS_CONF, "r", encoding="utf-8") as f:
              for line in f:
                  if line.startswith("# [profile:") and host_to_remove in line:
                      skip_block = True
                      removed = True
                      continue
                  if skip_block:
                      if line.strip() == "" or line.startswith("# [profile:"):
                          skip_block = False
                          if line.startswith("# [profile:"):
                              lines.append(line)
                      continue
                  lines.append(line)

          with open(HOSTS_CONF, "w", encoding="utf-8") as f:
              f.writelines(lines)

          if removed:
              console.print(f"[bold green]✔[/bold green] Removed profile for '[cyan]{host_to_remove}[/cyan]' from [dim]{HOSTS_CONF}[/dim]")
          else:
              console.print(f"[yellow][!] No matching profile found for '{host_to_remove}'.[/yellow]")

      def cmd_help():
          console.print(Panel.fit(
              "[bold cyan]kssh — Kitty SSH Kitten Interactive Profile Manager[/bold cyan]\n\n"
              "[bold]Usage:[/bold]\n"
              "  s [OPTIONS] [SSH_OPTIONS...] [USER@]HOST [COMMAND...]\n"
              "  kssh [OPTIONS] [SSH_OPTIONS...] [USER@]HOST [COMMAND...]\n\n"
              "[bold]Management Options:[/bold]\n"
              "  [green]-l, --list[/green]                  List all configured SSH endpoints and profiles\n"
              "  [green]-t, --templates[/green]             List all available connection templates\n"
              "  [green]-e, --edit[/green]                  Edit configured host profiles in $EDITOR\n"
              "  [green]--edit-template <NAME>[/green]      Edit or create a connection template\n"
              "  [green]-r, --remove <HOST>[/green]         Remove a host profile to re-trigger onboarding\n"
              "  [green]-h, --help[/green]                  Show this help guide\n\n"
              "[bold]Examples:[/bold]\n"
              "  s cluster                   # Connects to 'cluster' (prompts on first use)\n"
              "  s -p 2222 root@flint        # Connects with custom port/user\n"
              "  s --list                    # View formatted table of remembered hosts\n"
              "  s --templates               # Browse available connection templates\n"
              "  s --remove cluster          # Reset saved profile for 'cluster'\n",
              border_style="cyan"
          ))

      def interactive_onboarding(target, host, resolved_host):
          display_name = f"[bold cyan]{host}[/]"
          if resolved_host and resolved_host != host:
              display_name += f" [dim]({resolved_host})[/dim]"

          console.print()
          console.print(Panel(
              f"🚀 [bold white]First connection to endpoint:[/] {display_name}\n"
              f"[dim]Select a connection template to remember for this host:[/dim]",
              border_style="cyan",
              padding=(0, 2)
          ))

          templates = load_templates()
          choices = []
          for idx, tmpl in enumerate(templates, 1):
              default_tag = " (default)" if idx == 1 else ""
              choices.append(Choice(
                  title=f"[{tmpl['name']:<8}] • {tmpl['desc']}{default_tag}",
                  value=tmpl["name"]
              ))
          choices.append(Choice(title="[skip    ] • Connect once without saving profile", value="skip"))

          try:
              selected = questionary.select(
                  "Choose connection profile:",
                  choices=choices,
                  style=CUSTOM_STYLE,
                  use_indicator=True,
                  use_shortcuts=True
              ).ask()
          except KeyboardInterrupt:
              console.print("\n[red][!] Connection cancelled.[/red]")
              sys.exit(130)

          if not selected or selected == "skip":
              console.print("[dim]⚠ Connecting once without saving profile.[/dim]\n")
          else:
              save_profile(selected, host, resolved_host)
              console.print(f"[bold green]✔[/bold green] Configured [cyan]{host}[/cyan] with template [bold green]{selected}[/bold green] in [dim]{HOSTS_CONF}[/dim]\n")

      def main():
          ensure_dirs()
          args = sys.argv[1:]

          if not args or args == ["-h"] or args == ["--help"]:
              cmd_help()
              sys.exit(0)

          if args[0] in ("-l", "--list"):
              cmd_list()
              sys.exit(0)
          if args[0] in ("-t", "--templates"):
              cmd_templates()
              sys.exit(0)
          if args[0] in ("-e", "--edit"):
              cmd_edit()
              sys.exit(0)
          if args[0] == "--edit-template":
              name = args[1] if len(args) > 1 else ""
              cmd_edit_template(name)
              sys.exit(0)
          if args[0] in ("-r", "--remove"):
              host = args[1] if len(args) > 1 else ""
              cmd_remove(host)
              sys.exit(0)

          target = parse_target(args)
          if target and sys.stdin.isatty():
              bare_host = target.split("@")[-1].split(":")[0]
              resolved = resolve_canonical_host(target)
              candidates = [bare_host, target]
              if resolved and resolved != bare_host:
                  candidates.append(resolved)

              if not is_configured(candidates):
                  interactive_onboarding(target, bare_host, resolved)

          # Execute kitten ssh with all original arguments
          try:
              os.execvp("kitten", ["kitten", "ssh", *args])
          except FileNotFoundError:
              # Fallback to standard ssh if kitten is somehow not found
              os.execvp("ssh", ["ssh", *args])

      if __name__ == "__main__":
          main()
      '';
  in {
    packages.kssh = ksshScript;
  };
}

