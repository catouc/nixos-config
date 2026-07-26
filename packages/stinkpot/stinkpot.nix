{
  lib,
  buildGoModule,
}:

buildGoModule {
  pname      = "stinkpot";
  version    = "0.1.0";
  src        = fetchTarball {
    url="https://tangled.org/oppi.li/stinkpot/archive/main?format=tar.gz";
    sha256="sha256-65QVLKVRGIPSCBYDemGqqOBXvMWxvo0ms65bCaw9Bfg=";
  };
  vendorHash = "sha256-iDlU/176inkilehXft25KjiLt7rUtlMGqod22A3O/ko=";
}
