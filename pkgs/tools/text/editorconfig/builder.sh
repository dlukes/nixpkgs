source $stdenv/setup

tar xvzf $src
cd editorconfig*
cmake -DCMAKE_INSTALL_PREFIX=$out .
make install
