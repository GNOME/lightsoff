SUBDIRS = icons

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

appdatadir = $(datadir)/appdata
appdata_in_files = lightsoff.appdata.xml.in
appdata_DATA = $(appdata_in_files:.xml.in=.xml)
@INTLTOOL_XML_RULE@

CLEANFILES = \
	$(appdata_DATA)	\
	$(desktop_DATA)

EXTRA_DIST = \
	$(appdata_in_files) \
	$(lightsoff_DATA) \
	$(gsettings_SCHEMAS) \
	$(desktop_in_files)

check-local: $(appdata_DATA) $(desktop_DATA)
	/bin/true $(APPDATA_VALIDATE) $(appdata_DATA)
	$(DESKTOP_FILE_VALIDATE) $(desktop_DATA)

-include $(top_srcdir)/git.mk
