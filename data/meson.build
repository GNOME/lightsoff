# Icons
install_subdir('icons',
  install_dir: datadir,
  exclude_files: ['org.gnome.LightsOff.Source.svg']
)

# Make D-Bus activatable
service_conf = configuration_data()
service_conf.set('bindir', bindir)

service = 'org.gnome.LightsOff.service'

configure_file(
  input: service + '.in',
  output: service,
  install: true,
  install_dir: join_paths(datadir, 'dbus-1', 'services'),
  configuration: service_conf
)

# Desktop file
desktop = 'org.gnome.LightsOff.desktop'
desktop_file = i18n.merge_file(
  input: desktop + '.in',
  output: desktop,
  type: 'desktop',
  po_dir: podir,
  install: true,
  install_dir: join_paths(datadir, 'applications'),
)
desktop_file_validate = find_program('desktop-file-validate', required: false)
if desktop_file_validate.found()
  test(
    'validate-desktop',
    desktop_file_validate,
    args: [
      desktop_file.full_path()
    ]
  )
endif

# Metainfo
metainfo = 'org.gnome.LightsOff.metainfo.xml'
metainfo_file = i18n.merge_file(
  input: metainfo + '.in',
  output: metainfo,
  po_dir: podir,
  install: true,
  install_dir: join_paths(datadir, 'metainfo')
)
appstreamcli = find_program('appstreamcli', required: false)
if appstreamcli.found()
  test(
    'validate-metainfo', appstreamcli,
    args: [
      'validate', '--no-net', '--explain', metainfo_file.full_path()
    ]
  )
endif

# Install man page
install_man('@0@.6'.format(meson.project_name()))

# Gschema
install_data('org.gnome.LightsOff.gschema.xml',
  install_dir: join_paths(datadir, 'glib-2.0', 'schemas'),
)

