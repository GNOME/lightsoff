SUBDIRS = themes

lojsdir = $(pkgdatadir)/lightsoff
lojs_DATA = \
	About.js \
	Arrow.js \
	Board.js \
	Light.js \
	main.js \
	Game.js \
	LED.js \
	Settings.js \
	settings.ui \
	main-window.ui

bin_SCRIPTS = \
	lightsoff

schema_in_files = lightsoff.schemas.in
schemadir = $(GCONF_SCHEMA_FILE_DIR)
schema_DATA = $(schema_in_files:.schemas.in=.schemas)

desktop_in_files = lightsoff.desktop.in.in
desktopdir = $(datadir)/applications
desktop_DATA = $(desktop_in_files:.desktop.in.in=.desktop)
@INTLTOOL_DESKTOP_RULE@

CLEANFILES = main.js $(desktop_DATA)

EXTRA_DIST = \
	About.js \
	Arrow.js \
	Board.js \
	Light.js \
	main.js.in \
	Game.js \
	LED.js \
	Settings.js \
	settings.ui \
	main-window.ui

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

