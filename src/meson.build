lightsoff_vala_sources = [
  'board-view.vala',
  'board-view-gtk.vala',
  'lightsoff.vala',
  'lightsoff-window.vala',
  'puzzle-generator.vala',
  'game-view.vala',
  'game-view-gtk.vala',
  'managed-window.vala',
  'notifications-revealer.vala',
]

lightsoff_resources_file = files('lightsoff.gresource.xml')
lightsoff_resources = gnome.compile_resources('lightsoff.gresource.xml', lightsoff_resources_file)

sources = [
  lightsoff_vala_sources,
  lightsoff_resources
]

deps = [
  glib_dep,
  gio_dep,
  gtk_dep,
  librsvg_dep,
  libmath_dep,
  config_dep,
  posix_dep,
  libmath_dep,
  gmodule_dep,
]

vala_flags = [
  '--gresources', lightsoff_resources_file
]

c_flags = [
  '-DDATADIR="@0@"'.format(pkgdatadir),
  '-DLOCALEDIR="@0@"'.format(localedir),
  '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name())
]

executable('lightsoff', sources,
  dependencies: deps,
  include_directories: config_h_inc,
  c_args: c_flags,
  vala_args: vala_flags,
  install: true,
)
