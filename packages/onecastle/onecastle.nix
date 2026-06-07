{
  lib,
  buildGoModule,
}:

buildGoModule {
  pname      = "onecastle";
  version    = "0.1.0";
  src        = ./src;
  vendorHash = "sha256-ZCpjdt0rUo40yKDugYOdk9pe7o86mTZL7nzqnAVD5uY=";

  preInstall = ''
    mkdir -p $out/frontend
    cp -r ./frontend $out/
  '';
}
