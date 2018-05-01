# Icons
install_subdir('icons',
  install_dir: datadir,
)

# UI files
install_data(['off.svg', 'on.svg', 'highlight.svg'],
  install_dir: pkgdatadir,
)

desktop = 'lightsoff.desktop'

# Desktop file
i18n.merge_file(
  input: desktop + '.in',
  output: desktop,
  type: 'desktop',
  po_dir: podir,
  install: true,
  install_dir: join_paths(datadir, 'applications'),
)

appdata = 'lightsoff.appdata.xml'

# Appdata
i18n.merge_file(
  input: appdata + '.in',
  output: appdata,
  po_dir: podir,
  install: true,
  install_dir: join_paths(datadir, 'metainfo')
)

# Gschema
install_data('org.gnome.lightsoff.gschema.xml',
  install_dir: join_paths(datadir, 'glib-2.0', 'schemas'),
)

