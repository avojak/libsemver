libsemver_sources = files(
    'Specification.vala',
    'Util.vala',
    'Version.vala'
)

# Define all the names and versions
semver_gi_name = 'SemVer'
semver_gi_version = '1.0.0'

semver_gi = semver_gi_name + '-' + semver_gi_version
semver_gir = semver_gi + '.gir'
semver_typelib = semver_gi + '.typelib'

include_dir = join_paths(
    get_option('prefix'),
    get_option('includedir'),
    meson.project_name()
)

libsemver = library(
    meson.project_name (),

    libsemver_sources,

    dependencies: [
        libsemver_deps
    ],

    vala_header: 'semver-1.h',
    vala_vapi: 'semver-1.vapi',
    vala_gir: semver_gir,

    version: meson.project_version(),
    install: true,
    install_dir: [true, include_dir, true, true]
)

install_data(
    'semver-1.deps',
    install_dir: join_paths(get_option('datadir'), 'vala', 'vapi')
)

libsemver_dep = declare_dependency(
    link_with: libsemver,
    dependencies: libsemver_deps,
    include_directories: [include_directories('.')]
)

# generate pkgconfig file
semver_pc = pkgconfig.generate(
    libsemver,
    name: meson.project_name(),
    requires: libsemver_deps,
    subdirs: ['semver-1'],
    description: 'Semantic Version Library',
    version: meson.project_version(),
    url: 'https://github.com/avojak/libsemver',
)