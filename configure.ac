AC_PREREQ([2.63])
AC_INIT([Lights Off], [3.27.90], [https://bugzilla.gnome.org/],
        [lightsoff], [https://wiki.gnome.org/Apps/Lightsoff])
AC_CONFIG_MACRO_DIR([m4])

AM_INIT_AUTOMAKE([1.11 no-dist-gzip dist-xz foreign])
AM_SILENT_RULES([yes])
AM_MAINTAINER_MODE

AM_PROG_VALAC([0.22.0])
AM_PROG_CC_C_O

GLIB_GSETTINGS

APPSTREAM_XML

dnl ###########################################################################
dnl Dependencies
dnl ###########################################################################

GLIB_REQUIRED=2.38.0
GTK_REQUIRED=3.13.4
CLUTTER_REQUIRED=1.14.0
CLUTTER_GTK_REQUIRED=1.5.0
RSVG_REQUIRED=2.32.0

PKG_CHECK_MODULES(LIGHTSOFF, [
  glib-2.0 >= $GLIB_REQUIRED
  gtk+-3.0 >= $GTK_REQUIRED
  clutter-1.0 >= $CLUTTER_REQUIRED
  clutter-gtk-1.0 >= $CLUTTER_GTK_REQUIRED
  librsvg-2.0 >= $RSVG_REQUIRED
])

AC_SUBST([GLIB_REQUIRED])

AC_CHECK_LIB([m],[floor])

AC_PATH_PROG([DESKTOP_FILE_VALIDATE], [desktop-file-validate], [/bin/true])

dnl ###########################################################################
dnl GResources
dnl ###########################################################################

AC_PATH_PROG([GLIB_COMPILE_RESOURCES],[glib-compile-resources])

dnl ###########################################################################
dnl Internationalization
dnl ###########################################################################

AM_GNU_GETTEXT_VERSION([0.19.8])
AM_GNU_GETTEXT([external])
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
help/Makefile
src/Makefile
])
AC_OUTPUT
