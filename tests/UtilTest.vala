/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com> (https://avojak.com)
 */

namespace SemVer {

    public class UtilTest : GLib.Object {

        /**
         * Tests large number addition.
         */
        private static void test_addition () {
            assert_true (Util.large_number_addition ("0", "0") == "0");
            assert_true (Util.large_number_addition ("1", "0") == "1");
            assert_true (Util.large_number_addition ("0", "1") == "1");
            assert_true (Util.large_number_addition ("1", "1") == "2");
            assert_true (Util.large_number_addition ("123", "58") == "181");
            assert_true (Util.large_number_addition ("999", "1") == "1000");
            assert_true (Util.large_number_addition ("1", "999") == "1000");
            assert_true (Util.large_number_addition ("99999999999999999999998", "1") == "99999999999999999999999");
            assert_true (Util.large_number_addition ("99999999999999999999999", "1") == "100000000000000000000000");
        }

        /**
         * Tests large number subtraction.
         */
        private static void test_subtraction () {
            assert_true (Util.large_number_subtraction ("0", "0") == "0");
            assert_true (Util.large_number_subtraction ("1", "0") == "1");
            assert_true (Util.large_number_subtraction ("1", "1") == "0");
            assert_true (Util.large_number_subtraction ("2", "1") == "1");
            assert_true (Util.large_number_subtraction ("181", "58") == "123");
            assert_true (Util.large_number_subtraction ("121", "58") == "63");
            assert_true (Util.large_number_subtraction ("58", "121") == "-63");
            assert_true (Util.large_number_subtraction ("0", "1") == "-1");
            assert_true (Util.large_number_subtraction ("99999999999999999999999", "1") == "99999999999999999999998");
        }

        public static void main (string[] args) {
            GLib.Test.init (ref args);
            GLib.Test.add_func ("/util/addition", test_addition);
            GLib.Test.add_func ("/util/subtraction", test_subtraction);
            GLib.Test.run ();
        }

    }

}
