libsemver_sources = files(
    'Specification.vala',
    'Util.vala',
    'Version.vala'
)

# Define all the names and versions
semver_gi_name = 'SemVer'
semver_gi_version = '0.0.1'

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

    vala_header: 'semver-0.h',
    vala_vapi: 'semver-0.vapi',
    vala_gir: semver_gir,

    version: meson.project_version(),
    install: true,
    install_dir: [true, include_dir, true, true]
)