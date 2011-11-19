lightsoffdir = $(pkgdatadir)/lightsoff
lightsoff_DATA = \
	lightsoff.ui \
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

CLEANFILES = $(desktop_DATA) $(schema_DATA)
DISTCLEANFILES = $(desktop_DATA) $(schema_DATA)

EXTRA_DIST = \
	$(lightsoff_DATA) \
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
