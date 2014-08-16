bin_PROGRAMS = lightsoff

lightsoff_SOURCES = \
	board-view.vala \
	config.vapi \
	lightsoff.vala \
	puzzle-generator.vala \
	game-view.vala

lightsoff_VALAFLAGS = \
	--pkg posix \
	--pkg gmodule-2.0 \
	--pkg clutter-1.0 \
	--pkg clutter-gtk-1.0

lightsoff_CFLAGS = \
	-w \
	-DVERSION=\"$(VERSION)\" \
	-DGETTEXT_PACKAGE=\"$(GETTEXT_PACKAGE)\" \
	-DDATADIR=\""$(datadir)/lightsoff"\" \
	-DLOCALEDIR=\"$(datadir)/locale\" \
	$(LIGHTSOFF_CFLAGS)

lightsoff_LDADD =	\
	$(LIGHTSOFF_LIBS)

CLEANFILES = \
	$(patsubst %.vala,%.c,$(filter %.vala, $(SOURCES))) \
	*_vala.stamp

-include $(top_srcdir)/git.mk
