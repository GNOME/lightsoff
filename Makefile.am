SUBDIRS = data/themes help

lightsoffdir = $(pkgdatadir)/lightsoff
lightsoff_DATA = \
	src/About.js \
	src/Arrow.js \
	src/Board.js \
	src/Light.js \
	src/main.js \
	src/path.js \
	src/Game.js \
	src/LED.js \
	src/Settings.js \
	data/settings.ui \
	data/main-window.ui \
	src/ThemeLoader.js

bin_SCRIPTS = \
	src/lightsoff

schema_in_files = lightsoff.schemas.in
schemadir = $(GCONF_SCHEMA_FILE_DIR)
schema_DATA = $(schema_in_files:.schemas.in=.schemas)

desktop_in_files = lightsoff.desktop.in.in
desktopdir = $(datadir)/applications
desktop_DATA = $(desktop_in_files:.desktop.in.in=.desktop)
@INTLTOOL_DESKTOP_RULE@

CLEANFILES = $(desktop_DATA)

EXTRA_DIST = \
	src/About.js \
	src/Arrow.js \
	src/Board.js \
	src/Light.js \
	src/main.js \
	src/path.js.in \
	src/Game.js \
	src/LED.js \
	src/Settings.js \
	data/settings.ui \
	data/main-window.ui \
	src/ThemeLoader.js

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

