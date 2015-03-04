SUBDIRS = icons

dist_noinst_DATA = \
	lightsoff-menus.ui

lightsoffdir = $(datadir)/lightsoff
lightsoff_DATA = \
	off.svg \
	on.svg \
	highlight.svg

gsettings_SCHEMAS = org.gnome.lightsoff.gschema.xml
@GSETTINGS_RULES@

desktop_in_files = lightsoff.desktop.in
desktopdir = $(datadir)/applications
desktop_DATA = $(desktop_in_files:.desktop.in=.desktop)
@INTLTOOL_DESKTOP_RULE@

appstream_in_files = lightsoff.appdata.xml.in
appstream_XML = $(appstream_in_files:.xml.in=.xml)
@APPSTREAM_XML_RULES@
@INTLTOOL_XML_RULE@

CLEANFILES = \
	$(appstream_XML) \
	$(desktop_DATA)

EXTRA_DIST = \
	$(appstream_in_files) \
	$(lightsoff_DATA) \
	$(gsettings_SCHEMAS) \
	$(desktop_in_files)

check-local: $(desktop_DATA)
	$(DESKTOP_FILE_VALIDATE) $(desktop_DATA)

-include $(top_srcdir)/git.mk
