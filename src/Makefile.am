bin_PROGRAMS = lightsoff

lightsoff_SOURCES = \
	board-view.vala \
	config.vapi \
	fixes.vapi \
	lightsoff.vala \
	led-array.vala \
	puzzle-generator.vala \
	game-view.vala

lightsoff_VALAFLAGS = \
	--pkg posix \
	--pkg gmodule-2.0 \
	--pkg clutter-gtk-1.0 \
	--vapidir $(top_srcdir)/libgames-support \
	--pkg GnomeGamesSupport-1.0

lightsoff_CFLAGS = \
	-I$(top_srcdir)/libgames-support \
	-DVERSION=\"$(VERSION)\" \
	-DGETTEXT_PACKAGE=\"$(GETTEXT_PACKAGE)\" \
	-DPKGDATADIR=\""$(pkgdatadir)/lightsoff"\" \
	$(GHTREAD_CFLAGS) \
	$(GMODULE_CFLAGS) \
	$(GTK_CFLAGS) \
	$(CLUTTER_GTK_CFLAGS)

lightsoff_LDADD =	\
	$(top_builddir)/libgames-support/libgames-support.la \
	$(GTHREAD_LIBS)	\
	$(GMODULE_LIBS) \
	$(GTK_LIBS)	\
	$(CLUTTER_GTK_LIBS)	\
	$(INTLLIBS)

-include $(top_srcdir)/git.mk
