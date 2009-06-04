SUBDIRS = themes

lojsdir = $(pkgdatadir)/lightsoff
lojs_DATA = \
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

desktop_in_files = lightsoff.desktop.in.in
desktopdir = $(datadir)/applications
desktop_DATA = $(desktop_in_files:.desktop.in.in=.desktop)
@INTLTOOL_DESKTOP_RULE@

CLEANFILES = $(lojs_DATA) $(desktop_DATA)

EXTRA_DIST = \
	Arrow.js.in \
	Board.js.in \
	Light.js.in \
	main.js.in \
	Game.js.in \
	LED.js.in \
	Settings.js.in \
	settings.ui \
	main-window.ui
