self: super:

{
  mediawiki = super.mediawiki.overrideAttrs ( old: rec {
    version = "1.43.3"; 
    src = super.fetchurl {
      url = "https://releases.wikimedia.org/mediawiki/${super.lib.versions.majorMinor version}/mediawiki-${version}.tar.gz";
      hash = "sha256-5AnfQWuk2Z0nBeHrD/gWiGPbKnkcwL56h9s8E9mAGnA=";
    };
  });
}
