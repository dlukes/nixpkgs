{ stdenv, fetchurl, cmake, pcre }:

stdenv.mkDerivation rec {
  name = "editorconfig-core-c-0.12.0";

  buildInputs = [ cmake pcre ];
  builder = ./builder.sh;

  src = fetchurl {
    url = "http://downloads.sourceforge.net/project/editorconfig/EditorConfig-C-Core/0.12.0/source/${name}.tar.gz";
    md5 = "b2eefcc47656f4166f3326eeeaddc076";
  };

  meta = {
    description = "A library to maintain consistent coding conventions across editors.";
    homepage = https://github.com/editorconfig/editorconfig-core-c;
    platforms = stdenv.lib.platforms.all;
  };
}
