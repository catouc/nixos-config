{
  lib,
  buildGoModule,
}:

buildGoModule {
  pname      = "stinkpot";
  version    = "0.1.0";
  src        = fetchTarball {
    url="https://tangled.org/oppi.li/stinkpot/archive/8fa6de51adebb1ddeffbfb3b79c0885c2403575a?format=tar.gz";
    sha256="sha256-766l6US0ISPPO7ygPtYryInvLF9wF0q1fWc9IWlSGVY=";
  };
  vendorHash = "sha256-IVPACl1oWnBKGzcXvG5gzev8MwhzIKNI7zwEKJjhFc8=";
}
