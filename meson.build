project('semver', 'vala', 'c', version: '1.0.0')

glib_min_version = '2.50'
libsemver_deps = [
    dependency('gio-2.0', version: '>=' + glib_min_version),
    dependency('gio-unix-2.0', version: '>=' + glib_min_version),
    dependency('glib-2.0', version: '>=' + glib_min_version),
    dependency('gobject-2.0', version: '>=' + glib_min_version)
]

pkgconfig = import('pkgconfig')

subdir('lib')
subdir('tests')

if get_option('documentation')
    subdir('doc')
endif