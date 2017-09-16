SUBDIRS = icons

dist_noinst_DATA = \
	lightsoff-menus.ui \
	lightsoff.ui

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
$(desktop_DATA): $(desktop_in_files)
	$(AM_V_GEN)$(MSGFMT) --desktop --template $< -d $(top_srcdir)/po -o $@

appstream_in_files = lightsoff.appdata.xml.in
appstream_XML = $(appstream_in_files:.xml.in=.xml)
$(appstream_XML): $(appstream_in_files)
	$(AM_V_GEN)$(MSGFMT) --xml --template $< -d $(top_srcdir)/po -o $@

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
