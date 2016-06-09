{ stdenv, fetchurl, cmake, qt4, pkgconfig, neon, qtkeychain, sqlite }:

stdenv.mkDerivation rec {
  name = "owncloud-client" + "-" + version;

  version = "2.2.1";

  src = fetchurl {
    url = "https://github.com/owncloud/client/archive/v${version}.tar.gz";
    sha256 = "10pcgwjf104ly4m0adz3085ad99gci6n0jxipadfl0kz109spns9";
  };

  buildInputs =
    [ cmake qt4 pkgconfig neon qtkeychain sqlite];

  #configurePhase = ''
  #  mkdir build
  #  cd build
  #  cmake -DBUILD_WITH_QT4=on \
  #        -DCMAKE_INSTALL_PREFIX=$out \
  #        -DCMAKE_BUILD_TYPE=Release \
  #        ..
  #'';

  enableParallelBuilding = true;

  meta = {
    description = "Synchronise your ownCloud with your computer using this desktop client";
    homepage = https://owncloud.org;
    maintainers = with stdenv.lib.maintainers; [ qknight ];
    meta.platforms = stdenv.lib.platforms.unix;
  };
}
