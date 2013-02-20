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

desktop_in_files = lightsoff.desktop.in.in
desktopdir = $(datadir)/applications
desktop_DATA = $(desktop_in_files:.desktop.in.in=.desktop)
@INTLTOOL_DESKTOP_RULE@

CLEANFILES = $(desktop_DATA) $(gsettings_SCHEMAS)
DISTCLEANFILES = $(desktop_DATA) $(gsettings_SCHEMAS)

EXTRA_DIST = \
	$(lightsoff_DATA) \
	$(gsettings_in_file) \
	$(desktop_in_file)

-include $(top_srcdir)/git.mk
