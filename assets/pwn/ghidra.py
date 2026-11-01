import os
import select
import subprocess
import sys
import click

DEFAULT_GHIDRA = (
    "/opt/ghidra/"
)
GHIDRA_PATH = os.environ.get("GHIDRA_PATH", DEFAULT_GHIDRA)
if not GHIDRA_PATH.endswith("/"):
    GHIDRA_PATH += "/"


def shouldRun():
    msg = "will run analysis in 3 seconds, press any key to cancel"
    click.secho(msg, fg="yellow")
    i, _, _ = select.select([sys.stdin], [], [], 3)
    if i:
        return False
    return True


def run(filename):
    if os.path.isdir(filename):
        return os.system(f"{GHIDRA_PATH}ghidraRun")
    if ".gpr" in filename:
        os.system(f'{GHIDRA_PATH}ghidraRun "{os.path.abspath(filename)}"')
        return

    proj_file = filename + ".gpr"
    out_dir = os.path.join(os.path.dirname(filename), "ghidra")
    os.makedirs(out_dir, exist_ok=True)

    proj_name = os.path.splitext(os.path.basename(proj_file))[0]
    cmd = f'file "{filename}"'
    file_output = subprocess.check_output(cmd, shell=True).decode("utf8")
    click.secho(file_output, fg="yellow")
    os.system(f"checksec --file={filename}")
    print()
    if shouldRun():
        click.secho("running analysis on ", fg="green", nl=False)
        styled_name = click.style(
            f"./{os.path.basename(filename)}",
            bold=True,
        )
        click.secho(styled_name, fg="green")
        headless_bin = f"{GHIDRA_PATH}support/analyzeHeadless"
        analyze_cmd = (
            f'{headless_bin} {out_dir} "{proj_name}" '
            f'-import "{filename}" > /dev/null 2>&1'
        )
        os.system(analyze_cmd)
        target_gpr = os.path.join(out_dir, os.path.basename(proj_file))
        run_cmd = f'{GHIDRA_PATH}ghidraRun "{target_gpr}" > /dev/null 2>&1'
        os.system(run_cmd)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        cwd = os.getcwd()
    else:
        cwd = sys.argv[1]

    file_names = os.listdir(cwd)
    ghidra_dir = os.path.join(cwd, "ghidra")
    if "ghidra" in file_names and os.path.isdir(ghidra_dir):
        subfiles = os.listdir(ghidra_dir)
        for subfile in subfiles:
            if subfile.endswith(".gpr"):
                run(os.path.join(ghidra_dir, subfile))
                sys.exit(0)
    for file_name in file_names:
        if file_name.endswith("_patched"):
            run(os.path.join(cwd, file_name))
            sys.exit(0)
