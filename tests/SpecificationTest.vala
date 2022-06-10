/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com> (https://avojak.com)
 */

namespace SemVer {

    public class SpecificationTest : GLib.Object {

        /**
         * Tests that the SemVer spec version constants are correctly set.
         */
        private static void test_spec_version () {
            assert_true (SemVer.SPEC_MAJOR_VERSION == 2);
            assert_true (SemVer.SPEC_MINOR_VERSION == 0);
            assert_true (SemVer.SPEC_PATCH_VERSION == 0);
        }

        public static void main (string[] args) {
            GLib.Test.init (ref args);
            GLib.Test.add_func ("/specification/version", test_spec_version);
            GLib.Test.run ();
        }

    }

}
