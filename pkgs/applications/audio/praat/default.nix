{ stdenv, fetchurl, alsaLib, gtk, pkgconfig }:

stdenv.mkDerivation rec {
  name = "praat-${version}";
  version = "6.0.19";

  src = fetchurl {
    url = "https://github.com/praat/praat/archive/v${version}.tar.gz";
    sha256 = "1fhzqzygx5h6xkjaxwgzvnby393q7c3lby0fq3bnhscfdhzkm0a0";
  };

  configurePhase = ''
    cp makefiles/makefile.defs.linux.alsa makefile.defs
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp praat $out/bin
  '';

  buildInputs = [ alsaLib gtk pkgconfig ];

  meta = {
    description = "Doing phonetics by computer";
    homepage = http://www.fon.hum.uva.nl/praat/;
    license = stdenv.lib.licenses.gpl2Plus; # Has some 3rd-party code in it though
    platforms = stdenv.lib.platforms.linux;
  };
}
