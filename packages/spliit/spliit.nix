{
  stdenv,
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  prisma_7,
  prisma-engines_7,
  openssl,
}:

buildNpmPackage {
	pname = "spliit";
	version = "1.30.0";

	src = fetchFromGitHub {
		owner = "spliit-app";
		repo = "spliit";
		rev = "1.30.0";
		sha256 = "sha256-iOhCIFiEVGB/LGnvt+2RP57mQZBkybHaM53LPuutlfk=";
	};

	npmDepsHash = "sha256-uZuZOvsyUTslwYF1WMZENIxU2Guqe985hXF4b/D1VIM=";
  makeCacheWritable = true;
  npmFlags = [ "--legacy-peer-deps" ];
  npmInstallFlags = [ "--legacy-peer-deps" ];
	nativeBuildInputs = [ prisma_7 ];
	buildInputs = [ prisma-engines_7 openssl ];

	patches = [ ./package-lock.patch ];

	postPatch = ''
	  sed -i "/postinstall/d" package.json
	'';

	preBuild = ''
    export PRISMA_SCHEMA_ENGINE_BINARY="${prisma-engines_7}/bin/schema-engine"
    export PRISMA_QUERY_ENGINE_BINARY="${prisma-engines_7}/bin/query-engine"
    export PRISMA_QUERY_ENGINE_LIBRARY="${prisma-engines_7}/lib/libquery_engine.node"
    export PRISMA_FMT_BINARY="${prisma-engines_7}/bin/prisma-fmt"
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

    cp ./prisma.config.ts $out/prisma
    cp -r prisma/* $out/prisma	
    cp -r .next/standalone $out/share/spliit
    cp -r public $out/share/spliit/public
    cp -r .next/static $out/share/spliit/.next

    chmod +x $out/share/spliit/server.js
    makeWrapper $out/share/spliit/server.js $out/bin/spliit \
      --set-default PORT 3334 \
      --set PRISMA_SCHEMA_ENGINE_BINARY ${prisma-engines_7}/bin/schema-engine \
      --set PRISMA_QUERY_ENGINE_BINARY ${prisma-engines_7}/bin/query-engine \
      --set PRISMA_QUERY_ENGINE_LIBRARY ${prisma-engines_7}/lib/libquery_engine.node \
      --set PRISMA_FMT_BINARY ${prisma-engines_7}/bin/prisma-fmt \
      --set PRISMA_DISABLE_TELEMETRY 1 \
      --prefix PATH : ${ lib.makeBinPath [openssl] } \
      --prefix LD_LIBRARY_PATH : ${ lib.makeLibraryPath [ openssl ]}
      

    runHook postInstall
	'';
}
