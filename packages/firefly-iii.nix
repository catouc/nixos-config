{ php83, fetchFromGitHub }:
php83.buildComposerProject (finalAttrs: {
  pname = "firefly-iii";
  version = "6.1.12";
  vendorHash = "sha256-b/SoxbqE3HmGOpiDYG6QkvtE2YIf2lOhlvaFfVxTW3A=";

  src = fetchFromGitHub {
    owner = "firefly-iii";
    repo = "firefly-iii";
    rev = "v" + finalAttrs.version;
    hash = "sha256-nOE2WVz5xKewSKPkMm5c+8ME6gT5/kXvMYt9vVqzr+4=";
  };
})
