/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com> (https://avojak.com)
 */

/**
 * Internal utility functions.
 */
namespace SemVer.Util {

    /**
     * Performs safe addition of large numbers by breaking the string values down into
     * small integer chunks.
     */
    internal string large_number_addition (string a, string b) {
        // Determine the maximum possible length of the resulting string, accounting for potential carry
        int max_len = (a.length > b.length ? a.length : b.length) + 1;

        // Pad each string and convert to the array of parts
        uint8[] a_parts = (string.nfill (max_len - a.length, '0') + a).data;
        uint8[] b_parts = (string.nfill (max_len - b.length, '0') + b).data;
        // Create the result char array
        uint8[] result = string.nfill (max_len, '0').data;

        // Iterate over all parts, initially there is no value to carry
        int carry = 0;
        for (int i = max_len - 1; i >= 0; i--) {
            // Perform addition on the parsed parts. We can safely do normal integer addition here because the
            // maximum values are very small (no more than 9+9+1 if there is a carry).
            int intermediate = int.parse (((char) a_parts[i]).to_string ())
                    + int.parse (((char) b_parts[i]).to_string ())
                    + carry;
            // If the intermediate value is greater than 9 (i.e. double-digit), set the carry value and add the
            // least significant digit to the result array.
            if (intermediate > 9) {
                result[i] = intermediate.to_string ().data[1];
                carry = 1;
            } else {
                result[i] = intermediate.to_string ().data[0];
                carry = 0;
            }
        }

        // Remove the leading 0 if no value was carried into its place
        int offset = (char) result[0] == '0' ? 1 : 0;
        return ((string) result).substring (offset, max_len - offset);
    }

    /**
     * Performs safe subtraction of large numbers by breaking the string values down into
     * small integer chunks.
     */
    internal string large_number_subtraction (string a, string b) {
        // If a is less than b, flip the subtraction so we end up with a positive result, then flip the sign at the end
        if (large_number_compare (a, b) < 0) {
            var intermediate = large_number_subtraction (b, a);
            return @"-$intermediate";
        }
        // Determine the maximum possible length of the resulting string, including space for a possible negative sign
        int max_len = (a.length > b.length ? a.length : b.length) + 1;

        // Pad each string and convert to the array of parts
        uint8[] a_parts = (string.nfill (max_len - a.length, '0') + a).data;
        uint8[] b_parts = (string.nfill (max_len - b.length, '0') + b).data;
        // Create the result char array
        uint8[] result_chars = string.nfill (max_len, '0').data;

        // Iterate over all parts, initially there is no value to carry
        int carry = 0;
        for (int i = max_len - 1; i >= 0; i--) {
            // Perform subtraction on the parsed parts. We can safely do normal integer subtraction here because the
            // maximum values are very small.
            int a_part_numeric = int.parse (((char) a_parts[i]).to_string ());
            int b_part_numeric = int.parse (((char) b_parts[i]).to_string ());
            int intermediate = a_part_numeric - b_part_numeric - carry;
            // If the intermediate value is negative, redo the subtraction with the carried value and add the
            // least significant digit to the result array. Update carry value.
            if (intermediate < 0) {
                intermediate = (a_part_numeric + 10) - b_part_numeric - carry;
                result_chars[i] = (-1 * intermediate).to_string ().data[1];
                carry = 1;
            } else {
                result_chars[i] = intermediate.to_string ().data[0];
                carry = 0;
            }
        }

        string result = ((string) result_chars).substring (0, max_len);
        // Remove the leading zeroes
        while (result.has_prefix ("0") && result.length > 1) {
            result = result.substring (1);
        }
        return result;
    }

    internal int large_number_compare (string a, string b) {
        // First check for different signs
        if (a.has_prefix ("-") && !b.has_prefix ("-")) {
            return -1;
        }
        if (!a.has_prefix ("-") && b.has_prefix ("-")) {
            return 1;
        }
        // We know both numbers have the same sign now
        bool both_negative = a.has_prefix ("-") && b.has_prefix ("-");
        // Next check length, accounting for signs
        if (a.length < b.length) {
            if (both_negative) {
                return 1;
            } else {
                return -1;
            }
        }
        if (a.length > b.length) {
            if (both_negative) {
                return -1;
            } else {
                return 1;
            }
        }
        // Both numbers are the same sign and the same length, so we begin comparing for differences
        for (int i = 0; i < a.length; i++) {
            int a_numeric = int.parse (((char) a.data[i]).to_string ());
            int b_numeric = int.parse (((char) b.data[i]).to_string ());
            if (a_numeric == b_numeric) {
                continue;
            }
            return (int) (a_numeric > b_numeric) - (int) (a_numeric < b_numeric);
        }
        return 0;
    }

}
