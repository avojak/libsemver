/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com> (https://avojak.com)
 */

namespace SemVer {

    public class VersionTest : GLib.Object {

        /**
         * Tests that attempting to create a version from an invalid string will throw an error.
         */
        private static void test_create_invalid () {
            verify_invalid ("1");
            verify_invalid ("1.2");
            verify_invalid ("1.2.3-0123");
            verify_invalid ("1.2.3-0123.0123");
            verify_invalid ("1.1.2+.123");
            verify_invalid ("+invalid");
            verify_invalid ("-invalid");
            verify_invalid ("-invalid+invalid");
            verify_invalid ("-invalid.01");
            verify_invalid ("alpha");
            verify_invalid ("alpha.beta");
            verify_invalid ("alpha.beta.1");
            verify_invalid ("alpha.1");
            verify_invalid ("alpha+beta");
            verify_invalid ("alpha_beta");
            verify_invalid ("alpha.");
            verify_invalid ("alpha..");
            verify_invalid ("beta");
            verify_invalid ("1.0.0-alpha_beta");
            verify_invalid ("-alpha.");
            verify_invalid ("1.0.0-alpha..");
            verify_invalid ("1.0.0-alpha..1");
            verify_invalid ("1.0.0-alpha...1"); // vala-lint=ellipsis
            verify_invalid ("1.0.0-alpha....1"); // vala-lint=ellipsis
            verify_invalid ("1.0.0-alpha.....1"); // vala-lint=ellipsis
            verify_invalid ("1.0.0-alpha......1"); // vala-lint=ellipsis
            verify_invalid ("1.0.0-alpha.......1"); // vala-lint=ellipsis
            verify_invalid ("01.1.1");
            verify_invalid ("1.01.1");
            verify_invalid ("1.1.01");
            verify_invalid ("1.2");
            verify_invalid ("1.2.3.DEV");
            verify_invalid ("1.2-SNAPSHOT");
            verify_invalid ("1.2.31.2.3----RC-SNAPSHOT.12.09.1--..12+788");
            verify_invalid ("1.2-RC-SNAPSHOT");
            verify_invalid ("-1.0.3-gamma+b7718");
            verify_invalid ("+justmeta");
            verify_invalid ("9.8.7+meta+meta");
            verify_invalid ("9.8.7-whatever+meta+meta");
            verify_invalid ("99999999999999999999999.999999999999999999.99999999999999999----RC-SNAPSHOT.12.09.1--------------------------------..12"); // vala-lint=line-length
            verify_invalid ("0.0.4 ");
            verify_invalid (" 0.0.4");
        }

        private static void verify_invalid (string str) {
            try {
                new Version.from_string (str);
            } catch (VersionParseError e) {
                return;
            }
            critical ("Expected VersionParseError");
            GLib.Test.fail ();
        }

        /**
         * Tests that valid version strings are correctly decomposed into their parts/identifiers.
         */
        private static void test_identifiers () {
            verify_decomposition ("0.0.0", "0", "0", "0");
            verify_decomposition ("0.0.4", "0", "0", "4");
            verify_decomposition ("1.2.3", "1", "2", "3");
            verify_decomposition ("10.20.30", "10", "20", "30");
            verify_decomposition ("1.1.2-prerelease+meta", "1", "1", "2", "prerelease", "meta");
            verify_decomposition ("1.1.2+meta", "1", "1", "2", null, "meta");
            verify_decomposition ("1.1.2+meta-valid", "1", "1", "2", null, "meta-valid");
            verify_decomposition ("1.0.0-alpha", "1", "0", "0", "alpha");
            verify_decomposition ("1.0.0-beta", "1", "0", "0", "beta");
            verify_decomposition ("1.0.0-alpha.beta", "1", "0", "0", "alpha.beta");
            verify_decomposition ("1.0.0-alpha.beta.1", "1", "0", "0", "alpha.beta.1");
            verify_decomposition ("1.0.0-alpha.1", "1", "0", "0", "alpha.1");
            verify_decomposition ("1.0.0-alpha0.valid", "1", "0", "0", "alpha0.valid");
            verify_decomposition ("1.0.0-alpha.0valid", "1", "0", "0", "alpha.0valid");
            verify_decomposition ("1.0.0-alpha-a.b-c-somethinglong+build.1-aef.1-its-okay",
                    "1", "0", "0", "alpha-a.b-c-somethinglong", "build.1-aef.1-its-okay");
            verify_decomposition ("1.0.0-rc.1+build.1", "1", "0", "0", "rc.1", "build.1");
            verify_decomposition ("2.0.0-rc.1+build.123", "2", "0", "0", "rc.1", "build.123");
            verify_decomposition ("1.2.3-beta", "1", "2", "3", "beta");
            verify_decomposition ("10.2.3-DEV-SNAPSHOT", "10", "2", "3", "DEV-SNAPSHOT");
            verify_decomposition ("1.2.3-SNAPSHOT-123", "1", "2", "3", "SNAPSHOT-123");
            verify_decomposition ("1.0.0", "1", "0", "0");
            verify_decomposition ("2.0.0", "2", "0", "0");
            verify_decomposition ("1.1.7", "1", "1", "7");
            verify_decomposition ("2.0.0+build.1848", "2", "0", "0", null, "build.1848");
            verify_decomposition ("2.0.1-alpha.1227", "2", "0", "1", "alpha.1227");
            verify_decomposition ("1.0.0-alpha+beta", "1", "0", "0", "alpha", "beta");
            verify_decomposition ("1.2.3----RC-SNAPSHOT.12.9.1--.12+788",
                    "1", "2", "3", "---RC-SNAPSHOT.12.9.1--.12", "788");
            verify_decomposition ("1.2.3----R-S.12.9.1--.12+meta", "1", "2", "3", "---R-S.12.9.1--.12", "meta");
            verify_decomposition ("1.2.3----RC-SNAPSHOT.12.9.1--.12", "1", "2", "3", "---RC-SNAPSHOT.12.9.1--.12");
            verify_decomposition ("1.0.0+0.build.1-rc.10000aaa-kk-0.1",
                    "1", "0", "0", null, "0.build.1-rc.10000aaa-kk-0.1");
            verify_decomposition ("99999999999999999999999.999999999999999999.99999999999999999",
                    "99999999999999999999999", "999999999999999999", "99999999999999999");
            verify_decomposition ("1.0.0-0A.is.legal", "1", "0", "0", "0A.is.legal");
        }

        private static void verify_decomposition (string str, string major, string minor, string patch,
                string? prerelease = null, string? build_metadata = null) {
            var version = create_version (str);
            verify_parts (version, major, minor, patch, prerelease, build_metadata);
        }

        /**
         * Tests version precedence and compare_to.
         */
        private static void test_precedence () {
            verify_precedence ("1.0.0", "1.0.0", 0);
            verify_precedence ("1.0.0", "2.0.0", -1);
            verify_precedence ("2.0.0", "1.0.0", 1);

            verify_precedence ("1.0.0-alpha", "1.0.0-alpha", 0);
            verify_precedence ("1.0.0-alpha", "1.0.0", -1);
            verify_precedence ("1.0.0", "1.0.0-alpha", 1);

            verify_precedence ("1.0.0-alpha", "1.0.0-alpha.1", -1);
            verify_precedence ("1.0.0-alpha.1", "1.0.0-alpha.beta", -1);
            verify_precedence ("1.0.0-alpha.beta", "1.0.0-beta", -1);
            verify_precedence ("1.0.0-beta", "1.0.0-beta.2", -1);
            verify_precedence ("1.0.0-beta.2", "1.0.0-beta.11", -1);
            verify_precedence ("1.0.0-beta.11", "1.0.0-rc.1", -1);
            verify_precedence ("1.0.0-rc.1", "1.0.0", -1);

            verify_precedence ("1.0.0", "1.0.0+build.1848", 0);
            verify_precedence ("1.0.0+123", "1.0.0+build.1848", 0);

            verify_precedence ("99999999999999999999999.0.0", "99999999999999999999999.0.0", 0);
            verify_precedence ("99999999999999999999998.0.0", "99999999999999999999999.0.0", -1);
            verify_precedence ("99999999999999999999999.0.0", "99999999999999999999998.0.0", 1);

            verify_precedence ("18446744073709551615.0.0", "18446744073709551615.0.0", 0);
            verify_precedence ("18446744073709551615.0.0", "18446744073709551616.0.0", -1);
            verify_precedence ("18446744073709551616.0.0", "18446744073709551615.0.0", 1);
        }

        private static void verify_precedence (string a, string b, int res) {
            assert_true (create_version (a).compare_to (create_version (b)) == res);
        }

        private static void test_sorting () {
            var versions = new GLib.List<Version> ();
            versions.append (create_version ("2.0.0"));
            versions.append (create_version ("3.0.0"));
            versions.append (create_version ("1.0.0"));
            versions.sort ((a, b) => { return a.compare_to (b); });
            assert_true (versions.nth_data (0).to_string () == "1.0.0");
            assert_true (versions.nth_data (1).to_string () == "2.0.0");
            assert_true (versions.nth_data (2).to_string () == "3.0.0");
        }

        private static void test_increment () {
            verify_increment_major ("0.0.0", "1.0.0");
            verify_increment_major ("1.0.0", "2.0.0");
            verify_increment_major ("99999999999999999999999.0.0", "100000000000000000000000.0.0");
            verify_increment_minor ("1.2.3-beta", "1.3.3-beta");
            verify_increment_minor ("99999999999999999999999.0.0", "99999999999999999999999.1.0");
            verify_increment_patch ("1.0.0-beta+build.1", "1.0.1-beta+build.1");
            verify_increment_patch ("99999999999999999999999.0.0", "99999999999999999999999.0.1");
        }

        private static void verify_increment_major (string before, string after) {
            var before_version = create_version (before);
            before_version.increment_major_version ();
            assert_true (before_version.to_string () == after);
        }

        private static void verify_increment_minor (string before, string after) {
            var before_version = create_version (before);
            before_version.increment_minor_version ();
            assert_true (before_version.to_string () == after);
        }

        private static void verify_increment_patch (string before, string after) {
            var before_version = create_version (before);
            before_version.increment_patch_version ();
            assert_true (before_version.to_string () == after);
        }

        private static void test_decrement () {
            verify_decrement_major ("2.0.0", "1.0.0");
            verify_decrement_major ("1.0.0", "0.0.0");
            verify_decrement_major ("99999999999999999999999.0.0", "99999999999999999999998.0.0");
            verify_decrement_minor ("1.2.3-beta", "1.1.3-beta");
            verify_decrement_minor ("99999999999999999999999.3.0", "99999999999999999999999.2.0");
            verify_decrement_patch ("1.0.4-beta+build.1", "1.0.3-beta+build.1");
            verify_decrement_patch ("99999999999999999999999.0.2", "99999999999999999999999.0.1");
        }

        private static void verify_decrement_major (string before, string after) {
            var before_version = create_version (before);
            before_version.decrement_major_version ();
            assert_true (before_version.to_string () == after);
        }

        private static void verify_decrement_minor (string before, string after) {
            var before_version = create_version (before);
            before_version.decrement_minor_version ();
            assert_true (before_version.to_string () == after);
        }

        private static void verify_decrement_patch (string before, string after) {
            var before_version = create_version (before);
            before_version.decrement_patch_version ();
            assert_true (before_version.to_string () == after);
        }

        private static void test_decrement_unchanged () {
            verify_decrement_major_unchanged ("0.0.1");
            verify_decrement_minor_unchanged ("1.0.0-SNAPSHOT");
            verify_decrement_patch_unchanged ("0.1.0-beta+build.1");
        }

        private static void verify_decrement_major_unchanged (string str) {
            var version = create_version (str);
            version.decrement_major_version ();
            assert_true (version.to_string () == str);
        }

        private static void verify_decrement_minor_unchanged (string str) {
            var version = create_version (str);
            version.decrement_minor_version ();
            assert_true (version.to_string () == str);
        }

        private static void verify_decrement_patch_unchanged (string str) {
            var version = create_version (str);
            version.decrement_patch_version ();
            assert_true (version.to_string () == str);
        }

        private static void verify_parts (Version version, string major, string minor, string patch,
                string? prerelease = null, string? build_metadata = null) {
            assert_true (version.major == major);
            assert_true (version.minor == minor);
            assert_true (version.patch == patch);
            assert_true (version.prerelease == prerelease);
            assert_true (version.build_metadata == build_metadata);
        }

        private static Version create_version (string str) {
            try {
                return new Version.from_string (str);
            } catch (VersionParseError e) {
                critical (e.message);
                GLib.Test.fail ();
            }
            assert_not_reached ();
        }

        public static void main (string[] args) {
            GLib.Test.init (ref args);
            GLib.Test.add_func ("/create/invalid", test_create_invalid);
            GLib.Test.add_func ("/create/identifiers", test_identifiers);
            GLib.Test.add_func ("/precedence", test_precedence);
            GLib.Test.add_func ("/sorting", test_sorting);
            GLib.Test.add_func ("/update/increment", test_increment);
            GLib.Test.add_func ("/update/decrement", test_decrement);
            GLib.Test.add_func ("/update/decrement/invalid", test_decrement_unchanged);
            GLib.Test.run ();
        }

    }

}
