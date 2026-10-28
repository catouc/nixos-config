{
  stdenv,
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  prisma_6,
  prisma-engines_6,
  openssl,
}:

buildNpmPackage {
	pname = "spliit";
	version = "1.19.1";

	src = fetchFromGitHub {
		owner = "spliit-app";
		repo = "spliit";
		rev = "1.19.1";
		sha256 = "sha256-a2xz91g2tCkW+Si5mN2VQ29BE1PXHg4BBNdYt/gnIUs=";
	};

	npmDepsHash = "sha256-XBaFjoJpB6jE97G4hADdHRyywUn8gcgY0fb3DpV3NsE=";
	nativeBuildInputs = [ prisma_6 ];
	buildInputs = [ prisma-engines_6 openssl ];

	patches = [ ./nextjs-standalone.patch ];

	postPatch = ''
	  sed -i "/postinstall/d" package.json
	'';

	preBuild = ''
    export PRISMA_SCHEMA_ENGINE_BINARY="${prisma-engines_6}/bin/schema-engine"
    export PRISMA_QUERY_ENGINE_BINARY="${prisma-engines_6}/bin/query-engine"
    export PRISMA_QUERY_ENGINE_LIBRARY="${prisma-engines_6}/lib/libquery_engine.node"
    export PRISMA_FMT_BINARY="${prisma-engines_6}/bin/prisma-fmt"
    export LD_LIBRARY_PATH="${lib.makeLibraryPath [ openssl ]}"
    export PRISMA_DISABLE_TELEMETRY=1
    export POSTGRES_URL_NON_POOLING='postgres://localhost'
    export POSTGRES_PRISMA_URL='postgres://localhost'
	'';

	buildPhase = ''
    runHook prebBuild

    export POSTGRES_URL_NON_POOLING='postgres://localhost'
    export POSTGRES_PRISMA_URL='postgres://localhost'

    prisma generate
    npm run build

    runHook postBuild
	'';

	postBuild = ''
    sed -i '1s|^|#!/usr/bin/env node\n|' .next/standalone/server.js
    patchShebangs .next/standalone/server.js
	'';

	installPhase = ''
    runHook preInstall

    mkdir -p $out/{share,bin,prisma}

    cp -r prisma/* $out/prisma	
    cp -r .next/standalone $out/share/spliit
    cp -r public $out/share/spliit/public
    cp -r .next/static $out/share/spliit/.next

    chmod +x $out/share/spliit/server.js
    makeWrapper $out/share/spliit/server.js $out/bin/spliit \
      --set-default PORT 3334 \
      --set PRISMA_SCHEMA_ENGINE_BINARY ${prisma-engines_6}/bin/schema-engine \
      --set PRISMA_QUERY_ENGINE_BINARY ${prisma-engines_6}/bin/query-engine \
      --set PRISMA_QUERY_ENGINE_LIBRARY ${prisma-engines_6}/lib/libquery_engine.node \
      --set PRISMA_FMT_BINARY ${prisma-engines_6}/bin/prisma-fmt \
      --set PRISMA_DISABLE_TELEMETRY 1 \
      --prefix PATH : ${ lib.makeBinPath [openssl] } \
      --prefix LD_LIBRARY_PATH : ${ lib.makeLibraryPath [ openssl ]}
      

    runHook postInstall
	'';
}
