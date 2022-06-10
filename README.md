![CI](https://github.com/avojak/libsemver/actions/workflows/ci.yml/badge.svg)
![Lint](https://github.com/avojak/libsemver/actions/workflows/lint.yml/badge.svg)
![GitHub](https://img.shields.io/github/license/avojak/libsemver.svg?color=blue)
![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/avojak/libsemver?sort=semver)

# SemVer

SemVer is a GObject-based library for creating and handling Semantic Versions (https://semver.org).

## Features

- Parse existing `string`s as Semantic Versions
- Core version parts (i.e. major, minor, patch) implemented as `string`s to fully support the Semantic Versioning spec without an upper bound

## Example Usage

Creating a new `Version` object:

```vala
try {
    new SemVer.Version.from_string ("1.2.3-alpha+build.3");
} catch (SemVer.VersionParseError e) {
    warning (e.message);
}
```

Creating a new `Version` object from parts:

```vala
new SemVer.Version.from_parts ("1", "2", "3", "alpha", "build.3");
```

Retrieve individual parts of the version:

```vala
var version = new SemVer.Version.from_string ("1.2.3-alpha+build.3");
print (version.major);
// Output: "1"
print (version.minor);
// Output: "2"
print (version.patch);
// Output: "3"
print (version.prerelease);
// Output: "alpha"
print (version.build_metadata);
// Output: "build.3"
```

Converting a `Version` object to a `string`:

```vala
print (new SemVer.Version.from_parts ("0", "4", "2", "beta").to_string ());
// Output: "0.4.2-beta"
print (new SemVer.Version.from_parts ("5", "4", "0", null, "20220608").to_string ());
// Output: "5.4.0+20220608"
```

Incrementing core parts of the `Version` object:

```vala
var version = new SemVer.Version.from_string ("1.2.3");
version.increment_patch_version ();
print (version.to_string ());
// Output: "1.2.4"
```

Comparing precedence:

```vala
var a = new SemVer.Version.from_string ("1.0.0");
var b = new SemVer.Version.from_string ("2.0.0");
print ("%d", a.compare_to (b));
// Output: "-1"
print ("%d", b.compare_to (a));
// Output: "1"
print ("%d", a.compare_to (a));
// Output: "0"
```

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