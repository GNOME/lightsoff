SUBDIRS = data/themes

if BUILD_HELP
SUBDIRS += help
endif

lightsoffdir = $(pkgdatadir)/lightsoff
lightsoff_DATA = \
	src/About.js \
	src/Arrow.js \
	src/Board.js \
	src/Light.js \
	src/main.js \
	src/Path.js \
	src/Game.js \
	src/LED.js \
	src/Settings.js \
	data/settings.ui \
	data/lightsoff.ui \
	src/ThemeLoader.js

bin_SCRIPTS = \
	src/lightsoff

src/lightsoff: src/lightsoff.in Makefile
	$(AM_V_GEN) $(SED) -e "s|%pkglibdir%|$(pkglibdir)|" -e "s|%pkgdatadir%|$(pkgdatadir)|" $< > $@

src/Path.js: src/Path.js.in
	$(AM_V_GEN) $(SED) -e "s|%pkgdatadir%|$(pkgdatadir)|" $< > $@

schema_in_files = lightsoff.schemas.in
if HAVE_GNOME
schemadir = $(GCONF_SCHEMA_FILE_DIR)
schema_DATA = $(schema_in_files:.schemas.in=.schemas)
endif

desktop_in_files = lightsoff.desktop.in.in
desktopdir = $(datadir)/applications
desktop_DATA = $(desktop_in_files:.desktop.in.in=.desktop)
@INTLTOOL_DESKTOP_RULE@

CLEANFILES = $(desktop_DATA) $(schema_DATA)
DISTCLEANFILES = $(desktop_DATA) $(schema_DATA)

EXTRA_DIST = \
	src/lightsoff.in \
	src/About.js \
	src/Arrow.js \
	src/Board.js \
	src/Light.js \
	src/main.js \
	src/Path.js.in \
	src/Game.js \
	src/LED.js \
	src/Settings.js \
	data/settings.ui \
	data/lightsoff.ui \
	src/ThemeLoader.js \
	$(schema_in_files)

install-schemas-local: $(schema_DATA)
if GCONF_SCHEMAS_INSTALL
	if test -z "$(DESTDIR)" ; then \
		for p in $^ ; do \
			GCONF_CONFIG_SOURCE=$(GCONF_SCHEMA_CONFIG_SOURCE) $(GCONFTOOL) --makefile-install-rule $$p 2>&1 > /dev/null; \
		done \
	fi
endif

install-data-local: install-schemas-local

@INTLTOOL_SCHEMAS_RULE@

-include $(top_srcdir)/git.mk
