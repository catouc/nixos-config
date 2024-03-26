{ python3Packages, argparse, fetchurl }:
python3Packages.buildPythonPackage {
  pname = "ytdl_sub";
  version = "2023.10.28";
  format = "wheel";
  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/d7/31/e54f74f566c93b0088fdd5895e876d369b8384016747ee2898701458488f/ytdl_sub-2023.11.25-py3-none-any.whl";
    hash = "sha256-iah45MLJZwwfEYgCGLxu0WdT+85B2+NdG/TNPbp+C4U=";
  };
  doCheck = false;
  propagatedBuildInputs = [
    argparse
    python3Packages.colorama
    python3Packages.mediafile
    python3Packages.mergedeep
    python3Packages.pyyaml
    python3Packages.yt-dlp
  ];
}
