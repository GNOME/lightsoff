AC_PREREQ([2.63])
AC_INIT([Lights Off], [3.15.90], [https://bugzilla.gnome.org/],
        [lightsoff], [https://wiki.gnome.org/Apps/Lightsoff])
AM_INIT_AUTOMAKE([1.11 no-dist-gzip dist-xz foreign])
AM_SILENT_RULES([yes])
AM_MAINTAINER_MODE
GNOME_MAINTAINER_MODE_DEFINES

AM_PROG_VALAC([0.22.0])
AM_PROG_CC_C_O

GLIB_GSETTINGS

APPSTREAM_XML

dnl ###########################################################################
dnl Dependencies
dnl ###########################################################################

GTK_REQUIRED=3.13.2
CLUTTER_REQUIRED=1.14.0
CLUTTER_GTK_REQUIRED=1.5.0
RSVG_REQUIRED=2.32.0

PKG_CHECK_MODULES(LIGHTSOFF, [
  gtk+-3.0 >= $GTK_REQUIRED
  clutter-1.0 >= $CLUTTER_REQUIRED
  clutter-gtk-1.0 >= $CLUTTER_GTK_REQUIRED
  librsvg-2.0 >= $RSVG_REQUIRED
])

AC_CHECK_LIB([m],[floor])

AC_PATH_PROG([DESKTOP_FILE_VALIDATE], [desktop-file-validate], [/bin/true])

dnl ###########################################################################
dnl Internationalization
dnl ###########################################################################

IT_PROG_INTLTOOL([0.50])
AC_SUBST(GETTEXT_PACKAGE, lightsoff)

dnl ###########################################################################
dnl Documentation
dnl ###########################################################################

YELP_HELP_INIT

dnl ###########################################################################
dnl Files to generate
dnl ###########################################################################

AC_CONFIG_FILES([
Makefile
po/Makefile.in
data/Makefile
data/icons/Makefile
data/icons/hicolor/Makefile
data/icons/HighContrast/Makefile
help/Makefile
src/Makefile
])
AC_OUTPUT
