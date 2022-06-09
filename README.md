# SemVer

SemVer is a GObject-based library for creating and handling Semantic Versions (https://semver.org).

## Building, Testing, and Installation

Run `meson build` to configure the build environment:

```bash
meson build --prefix=/usr
```

This will create a `build` directory.

To build and install SemVer, use `ninja`:

```bash
ninja -C build install
```

To run tests:

```bash
ninja -C build test
```

There's also a Makefile if you're lazy like me and don't want to type those commands all the time.

## Documentation

The additional requirements for building the documentation are:

- valadoc

To generate the valadoc documentation, pass the additional `-Ddocumentation=true` flag to Meson, and then run `ninja` as before.