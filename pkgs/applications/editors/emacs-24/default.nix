{ stdenv, fetchurl, ncurses, xlibsWrapper, libXaw, libXpm, Xaw3d
, pkgconfig, gettext, libXft, dbus, libpng, libjpeg, libungif
, libtiff, librsvg, texinfo, gconf, libxml2, imagemagick, gnutls
, alsaLib, cairo, acl, gpm, AppKit, makeWrapper
, withX ? !stdenv.isDarwin
, withGTK3 ? false, gtk3 ? null
, withGTK2 ? true, gtk2
}:

assert (libXft != null) -> libpng != null;      # probably a bug
assert stdenv.isDarwin -> libXaw != null;       # fails to link otherwise
assert withGTK2 -> withX || stdenv.isDarwin;
assert withGTK3 -> withX || stdenv.isDarwin;
assert withGTK2 -> !withGTK3 && gtk2 != null;
assert withGTK3 -> !withGTK2 && gtk3 != null;

let
  toolkit =
    if withGTK3 then "gtk3"
    else if withGTK2 then "gtk2"
    else "lucid";
in

stdenv.mkDerivation rec {
  name = "emacs-24.5";

  builder = ./builder.sh;

  src = fetchurl {
    url    = "mirror://gnu/emacs/${name}.tar.xz";
    sha256 = "0kn3rzm91qiswi0cql89kbv6mqn27rwsyjfb8xmwy9m5s8fxfiyx";
  };

  icon = fetchurl {
    url    = "https://raw.githubusercontent.com/syl20bnr/spacemacs/master/assets/spacemacs.svg";
    sha256 = "85700ee004fac81c58fdea353b1fd7c2b3ead2ee630f2988b94eba068e3ec072";
  };

  patches = stdenv.lib.optionals stdenv.isDarwin [
    ./at-fdcwd.patch
  ];

  postPatch = ''
    sed -i 's|/usr/share/locale|${gettext}/share/locale|g' lisp/international/mule-cmds.el
  '';

  buildInputs =
    [ ncurses gconf libxml2 gnutls alsaLib pkgconfig texinfo acl gpm gettext ]
    ++ stdenv.lib.optional stdenv.isLinux dbus
    ++ stdenv.lib.optionals withX
      [ xlibsWrapper libXaw Xaw3d libXpm libpng libjpeg libungif libtiff librsvg libXft
        imagemagick gconf makeWrapper ]
    ++ stdenv.lib.optional (withX && withGTK2) gtk2
    ++ stdenv.lib.optional (withX && withGTK3) gtk3
    ++ stdenv.lib.optional (stdenv.isDarwin && withX) cairo;

  propagatedBuildInputs = stdenv.lib.optional stdenv.isDarwin AppKit;

  configureFlags =
    if stdenv.isDarwin
      then [ "--with-ns" "--disable-ns-self-contained" ]
    else if withX
      then [ "--with-x-toolkit=${toolkit}" "--with-xft" ]
      else [ "--with-x=no" "--with-xpm=no" "--with-jpeg=no" "--with-png=no"
             "--with-gif=no" "--with-tiff=no" ];

  NIX_CFLAGS_COMPILE = stdenv.lib.optionalString (stdenv.isDarwin && withX)
    "-I${cairo}/include/cairo";

  postInstall = ''
    mkdir -p $out/share/emacs/site-lisp/
    cp ${./site-start.el} $out/share/emacs/site-lisp/site-start.el
    find $out -name emacs.svg -exec cp $icon {} \;
    icon=`find $out -name emacs.svg | head -n 1`
    find $out -name emacs.png -exec rm {} \;
    # a dummy wrapper around nothing, specify a custom exec
    makeWrapper "" "$out/bin/.emacs-desktop" \
      --set TMPDIR '/tmp/$USER' \
      --set XLIB_SKIP_ARGB_VISUALS 1 \
      --run "exec -a \"\$0\" $out/bin/emacsclient -c -a $out/bin/.emacs-nbi \"\''${extraFlagsArray[@]}\" \"\$@\""
    # --no-bitmap-icon lets the WM use a custom icon if it exists
    makeWrapper "$out/bin/emacs" "$out/bin/.emacs-nbi" \
      --add-flags --no-bitmap-icon
    # configure desktop file to run .emacs-desktop instead of emacs, and change
    # icon
    sed -ri 's/emacs %F/.emacs-desktop %F/' $out/share/applications/emacs.desktop
    sed -ri "s|Icon=emacs|Icon=$icon|" $out/share/applications/emacs.desktop
  '' + stdenv.lib.optionalString stdenv.isDarwin ''
    mkdir -p $out/Applications
    mv nextstep/Emacs.app $out/Applications
  '';

  doCheck = true;

  meta = with stdenv.lib; {
    description = "GNU Emacs 24, the extensible, customizable text editor";
    homepage    = http://www.gnu.org/software/emacs/;
    license     = licenses.gpl3Plus;
    maintainers = with maintainers; [ chaoflow lovek323 simons the-kenny ];
    platforms   = platforms.all;

    # So that Exuberant ctags is preferred
    priority = 1;

    longDescription = ''
      GNU Emacs is an extensible, customizable text editor—and more.  At its
      core is an interpreter for Emacs Lisp, a dialect of the Lisp
      programming language with extensions to support text editing.

      The features of GNU Emacs include: content-sensitive editing modes,
      including syntax coloring, for a wide variety of file types including
      plain text, source code, and HTML; complete built-in documentation,
      including a tutorial for new users; full Unicode support for nearly all
      human languages and their scripts; highly customizable, using Emacs
      Lisp code or a graphical interface; a large number of extensions that
      add other functionality, including a project planner, mail and news
      reader, debugger interface, calendar, and more.  Many of these
      extensions are distributed with GNU Emacs; others are available
      separately.
    '';
  };
}
