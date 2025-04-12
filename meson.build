project('lightsoff', ['c','vala'],
	version: '48.1',
	meson_version: '>= 0.56.0',
	license: 'GPLv2+'
)

gnome = import('gnome')
i18n = import('i18n')

localedir   = join_paths(get_option('prefix'), get_option('localedir'))
datadir     = join_paths(get_option('prefix'), get_option('datadir'))
bindir      = join_paths(get_option('prefix'), get_option('bindir'))
pkgdatadir  = join_paths(datadir, 'lightsoff')

podir       = join_paths(meson.project_source_root(), 'po')
vapidir     = join_paths(meson.project_source_root(), 'vapi')

# Dependencies
glib_min_version = '2.38'

glib_dep = dependency('glib-2.0', version: '>= ' + glib_min_version)
gmodule_dep = dependency('gmodule-2.0')
gio_dep = dependency('gio-2.0', version: '>= ' + glib_min_version)
gtk_dep = dependency('gtk4', version: '>= 4.14.0')
libadwaita_dep = dependency('libadwaita-1', version: '>= 1.6.0')

# Check for compilers
valac = meson.get_compiler('vala')
cc = meson.get_compiler('c')

# Libraries
libmath_dep = cc.find_library('m')
config_dep = valac.find_library('config', dirs: vapidir)
posix_dep = valac.find_library('posix')

# Configuration
conf = configuration_data()

conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('LOCALEDIR', localedir)
conf.set_quoted('DATADIR', pkgdatadir)
conf.set_quoted('VERSION', meson.project_version())

config_h_inc = include_directories('.')

# Subdirs
subdir('data')
subdir('help')
subdir('po')
subdir('src')

config_file = configure_file(output: 'config.h', configuration: conf)

# Extra scripts
meson.add_install_script('build-aux/meson_post_install.py')
