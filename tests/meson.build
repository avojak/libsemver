unit_test_files = [
    'Specification',
    'Util',
    'Version'
]

foreach name : unit_test_files
    test(name, executable(name, name + 'Test.vala', libsemver_sources, dependencies: libsemver_deps, install: false))
endforeach