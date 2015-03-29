bin_PROGRAMS = lightsoff

BUILT_SOURCES = lightsoff-resources.c

lightsoff_SOURCES = \
	board-view.vala \
	config.vapi \
	lightsoff.vala \
	puzzle-generator.vala \
	game-view.vala \
	$(BUILT_SOURCES)

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

lightsoff-resources.c: $(shell $(GLIB_COMPILE_RESOURCES) --generate-dependencies lightsoff.gresource.xml)
	$(AM_V_GEN) $(GLIB_COMPILE_RESOURCES) --target=$@ --sourcedir=$(srcdir) --generate-source $(srcdir)/lightsoff.gresource.xml

CLEANFILES = \
	$(patsubst %.vala,%.c,$(filter %.vala, $(SOURCES))) \
	*_vala.stamp

EXTRA_DIST = lightsoff.gresource.xml

-include $(top_srcdir)/git.mk
