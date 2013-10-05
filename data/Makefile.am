SUBDIRS = icons

lightsoffdir = $(datadir)/lightsoff
lightsoff_DATA = \
	arrow.svg \
	backing.svg \
	led-back.svg \
	off.svg \
	on.svg \
	highlight.svg

gsettings_in_file = org.gnome.lightsoff.gschema.xml.in
gsettings_SCHEMAS = $(gsettings_in_file:.xml.in=.xml)
@INTLTOOL_XML_NOMERGE_RULE@
@GSETTINGS_RULES@

desktop_in_files = lightsoff.desktop.in
desktopdir = $(datadir)/applications
desktop_DATA = $(desktop_in_files:.desktop.in=.desktop)
@INTLTOOL_DESKTOP_RULE@

appdatadir = $(datadir)/appdata
appdata_DATA = lightsoff.appdata.xml

CLEANFILES = $(desktop_DATA) $(gsettings_SCHEMAS)
DISTCLEANFILES = $(gsettings_SCHEMAS)

EXTRA_DIST = \
	$(appdata_DATA) \
	$(lightsoff_DATA) \
	$(gsettings_in_file) \
	$(desktop_in_files)

check-local: $(appdata_DATA) $(desktop_DATA)
	$(APPDATA_VALIDATE) $(appdata_DATA)
	$(DESKTOP_FILE_VALIDATE) $(desktop_DATA)

-include $(top_srcdir)/git.mk
