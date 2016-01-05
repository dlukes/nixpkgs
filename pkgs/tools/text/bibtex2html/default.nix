{ stdenv, fetchurl, ocaml }:

stdenv.mkDerivation rec {
  name = "bibtex2html-1.98";
  src = fetchurl {
    url = "http://www.lri.fr/~filliatr/ftp/bibtex2html/${name}.tar.gz";
    sha256 = "1mh6hxmc9qv05hgjc11m2zh5mk9mk0kaqp59pny18ypqgfws09g9";
  };

  buildInputs = [ ocaml ];

  meta = {
    description = "Generate HTML bibliographies from .bib files.";
    homepage = https://www.lri.fr/~filliatr/bibtex2html/;
    license = stdenv.lib.licenses.gpl2;
    platforms = stdenv.lib.platforms.all;
  };
}
