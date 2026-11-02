{...}: {
  perSystem = {pkgs, ...}: {
    packages.mtp = pkgs.python3Packages.buildPythonApplication {
      pname = "mtp";
      version = "1.1.0";
      pyproject = true;
      build-system = [pkgs.python3Packages.setuptools];
      src = pkgs.python3Packages.fetchPypi {
        pname = "mtp";
        version = "1.1.0";
        sha256 = "4b44a89c3dee8936f9ae92eff3bebfc5839340d1c58c196b4bb7aa3f11f10c0c";
      };
      postPatch = ''
        substituteInPlace setup.py \
          --replace-fail "scripts=['cli.py']" "py_modules=['cli']"
      '';
      propagatedBuildInputs = [pkgs.python3Packages.urwid];
      nativeBuildInputs = [pkgs.python3Packages.pythonRelaxDepsHook];
      pythonRelaxDeps = ["urwid"];
      doCheck = false;
    };
  };
}
