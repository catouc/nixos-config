{ python3Packages, xdotool, fetchurl }:
python3Packages.buildPythonPackage {
  pname = "i3-layouts";
  version = "0.13.2";
  format = "wheel";
  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/e5/1c/5bf3a2a32decc7c3b0b8c9b43ffedabb0ac128a32e86517b0972e0ffb182/i3_layouts-0.13.2-py3-none-any.whl";
    hash = "sha256-BurW7zzjSSIbp5bD7zjCuK2D6T9SEhJu9zgEl9lw8IE=";
  };
  doCheck = false;
  propagatedBuildInputs = [
    xdotool
    python3Packages.i3ipc
  ];
}
