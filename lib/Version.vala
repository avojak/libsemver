/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com> (https://avojak.com)
 */

namespace SemVer {

    public errordomain VersionParseError {

        /**
         * Invalid SemVer string.
         */
        INVALID_SEMVER_STRING,
        /**
         * Invalid SemVer identifier.
         */
        INVALID_SEMVER_IDENTIFIER;

    }

    public class Version : GLib.Object {

        private const string CORE_VERSION_DELIM = ".";
        private const string PRERELEASE_PREFIX = "-";
        private const string PRERELEASE_DELIM = ".";
        private const string BUILD_METADATA_PREFIX = "+";

        private const string DEFAULT_CORE_VERSION_PART = "0";

        private const string MAJOR_PART_NAME = "major";
        private const string MINOR_PART_NAME = "minor";
        private const string PATCH_PART_NAME = "patch";
        private const string PRERELEASE_PART_NAME = "prerelease";
        private const string BUILD_METADATA_PART_NAME = "buildmetadata";

        // Provided by https://semver.org
        private const string MAJOR_VERSION_REGEX_STR = """(?P<major>0|[1-9]\d*)""";
        private const string MINOR_VERSION_REGEX_STR = """(?P<minor>0|[1-9]\d*)""";
        private const string PATCH_VERSION_REGEX_STR = """(?P<patch>0|[1-9]\d*)""";
        private const string PRERELEASE_REGEX_STR = """(?P<prerelease>(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*)"""; // vala-lint=line-length
        private const string BUILD_METADATA_REGEX_STR = """(?P<buildmetadata>[0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*)""";
        private const string REGEX_STR = """^(?P<major>0|[1-9]\d*)\.(?P<minor>0|[1-9]\d*)\.(?P<patch>0|[1-9]\d*)(?:-(?P<prerelease>(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+(?P<buildmetadata>[0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$"""; // vala-lint=line-length

        private static GLib.Regex major_version_regex;
        private static GLib.Regex minor_version_regex;
        private static GLib.Regex patch_version_regex;
        private static GLib.Regex prerelease_regex;
        private static GLib.Regex build_metadata_regex;
        private static GLib.Regex regex;

        /**
         * The major version part.
         */
        public string major { get; private set; }

        /**
         * The minor version part.
         */
        public string minor { get; private set; }

        /**
         * The patch version part.
         */
        public string patch { get; private set; }

        /**
         * The prerelease identifier.
         */
        public string? prerelease { get; private set; }

        /**
         * The build metadata identifier. Build metadata does not affect order precedence.
         */
        public string? build_metadata { get; private set; }

        static construct {
            try {
                major_version_regex = new GLib.Regex (MAJOR_VERSION_REGEX_STR, GLib.RegexCompileFlags.OPTIMIZE);
                minor_version_regex = new GLib.Regex (MINOR_VERSION_REGEX_STR, GLib.RegexCompileFlags.OPTIMIZE);
                patch_version_regex = new GLib.Regex (PATCH_VERSION_REGEX_STR, GLib.RegexCompileFlags.OPTIMIZE);
                prerelease_regex = new GLib.Regex (PRERELEASE_REGEX_STR, GLib.RegexCompileFlags.OPTIMIZE);
                build_metadata_regex = new GLib.Regex (BUILD_METADATA_REGEX_STR, GLib.RegexCompileFlags.OPTIMIZE);
                regex = new GLib.Regex (REGEX_STR, GLib.RegexCompileFlags.OPTIMIZE);
            } catch (GLib.RegexError e) {
                critical ("Error while constructing regex: %s", e.message);
            }
        }

        /**
         * Construction with providing initial parts is disallowed.
         */
        private Version () { }

        /**
         * Creates a new {@link Version} from a string.
         *
         * @param str The string to parse into a {@link Version}.
         *
         * @return The newly created {@link Version}.
         *
         * @throws VersionParseError If the supplied version string is invalid.
         */
        public Version.from_string (string str) throws VersionParseError {
            // First verify that the provided string matches the SemVer regex
            if (!regex.match (str, GLib.RegexMatchFlags.ANCHORED)) {
                throw new VersionParseError.INVALID_SEMVER_STRING ("Invalid SemVer string: \"%s\"".printf (str));
            }
            // Extract the version parts/identifiers from the string
            try {
                regex.replace_eval (str, -1, 0, GLib.RegexMatchFlags.ANCHORED, (match_info, result) => {
                    this.major = match_info.fetch_named (MAJOR_PART_NAME);
                    this.minor = match_info.fetch_named (MINOR_PART_NAME);
                    this.patch = match_info.fetch_named (PATCH_PART_NAME);
                    this.prerelease = or_null (match_info.fetch_named (PRERELEASE_PART_NAME));
                    this.build_metadata = or_null (match_info.fetch_named (BUILD_METADATA_PART_NAME));
                    return false;
                });
            } catch (GLib.RegexError e) {
                critical (e.message);
            }
        }

        /**
         * Creates a new {@link Version} from individual versrion parts.
         *
         * @param major The major version part.
         * @param minor The minor version part.
         * @param patch The patch version part.
         * @param prerelease The prerelease version identifier.
         * @param build_metadata The build metadata version identifier.
         *
         * @return The newly created {@link Version}.
         *
         * @throws VersionParseError If any of the supplied parts are invalid.
         */
        public Version.from_parts (string major, string minor, string patch, string? prerelease = null,
                string? build_metadata = null) throws VersionParseError {
            this.set_major_version (major);
            this.set_minor_version (minor);
            this.set_patch_version (patch);
            this.set_prerelease_identifier (prerelease);
            this.set_build_metadata_identifier (build_metadata);
        }

        /**
         * Fixes the case where there is a buildmetadata, but no prerelease field. The prerelease value
         * would be set to an empty string, but we want it to be null.
         */
        private static string? or_null (string? str) {
            if (str != null && str.length == 0) {
                return null;
            }
            return str;
        }

        /**
         * A comparison function for {@link Version}. Both {@link Version} objects must be non-null. 
         * 
         * @return -1, 0, or 1 if this is less than, equal to or greater in precedence than the other version.
         */
        public int compare_to (Version other) {
            // Sort by major, then minor, then patch. Continue if equal.
            if (this.major != other.major) {
                //  return (int) (this.major > other.major) - (int) (this.major < other.major);
                return Util.large_number_compare (this.major, other.major);
            }
            if (this.minor != other.minor) {
                //  return (int) (this.minor > other.minor) - (int) (this.minor < other.minor);
                return Util.large_number_compare (this.minor, other.minor);
            }
            if (this.patch != other.patch) {
                //  return (int) (this.patch > other.patch) - (int) (this.patch < other.patch);
                return Util.large_number_compare (this.patch, other.patch);
            }

            // A version with a prerelease will sort lower than a version without.
            if (this.prerelease == null && other.prerelease == null) {
                return 0;
            }
            if (this.prerelease == null && other.prerelease != null) {
                return 1;
            }
            if (this.prerelease != null && other.prerelease == null) {
                return -1;
            }

            // Compare the prerelease fields
            if (this.prerelease != null && other.prerelease != null) {
                string[] this_prerelease_identifiers = this.prerelease.split (PRERELEASE_DELIM);
                string[] other_prerelease_identifiers = other.prerelease.split (PRERELEASE_DELIM);

                int min_identifiers = this_prerelease_identifiers.length < other_prerelease_identifiers.length
                        ? this_prerelease_identifiers.length
                        : other_prerelease_identifiers.length;
                for (int i = 0; i < min_identifiers; i++) {
                    string this_identifier = this_prerelease_identifiers[i];
                    string other_identifier = other_prerelease_identifiers[i];

                    uint64 this_numeric;
                    uint64 other_numeric;
                    bool is_this_numeric = uint64.try_parse (this_identifier, out this_numeric);
                    bool is_other_numeric = uint64.try_parse (other_identifier, out other_numeric);

                    // Identifiers consisting of only digits are compared numerically. Continue if equal.
                    if (is_this_numeric && is_other_numeric && (this_numeric != other_numeric)) {
                        return (int) (this_numeric > other_numeric) - (int) (this_numeric < other_numeric);
                    }
                    // Identifiers with letters or hyphens are compared lexically in ASCII sort order. Continue if equal.
                    if (!is_this_numeric && !is_other_numeric && (this_identifier != other_identifier)) {
                        return ascii_cmp (this_identifier, other_identifier);
                    }
                    // Numeric identifiers always have lower precedence than non-numeric identifiers. Continue if equal.
                    if (is_this_numeric && !is_other_numeric) {
                        return -1;
                    }
                    if (!is_this_numeric && is_other_numeric) {
                        return 1;
                    }
                }

                // Up to this point all pre-release identifiers are equal, so we check if one version contains more fields. 
                // A larger set of pre-release fields has a higher precedence than a smaller set. Continue if equal.
                if (this_prerelease_identifiers.length > other_prerelease_identifiers.length) {
                    return 1;
                }
                if (this_prerelease_identifiers.length < other_prerelease_identifiers.length) {
                    return -1;
                }

            }

            // All pre-release identifiers are equal, and build metadata has no effect on precedence. At this point the versions are equal.
            return 0;
        }

        /**
         * Perform ASCII string comparison. If all prior characters are equal, a longer string
         * has a higher precendence.
         */
        private int ascii_cmp (string a, string b) {
            uint8[] a_chars = a.data;
            uint8[] b_chars = b.data;
            int min_chars = a_chars.length < b_chars.length ? a_chars.length : b_chars.length;
            for (int i = 0; i < min_chars; i++) {
                if (a_chars[i] == b_chars[i]) {
                    continue;
                }
                return (int) (a_chars[i] > b_chars[i]) - (int) (a_chars[i] < b_chars[i]);
            }
            if (a_chars.length > b_chars.length) {
                return 1;
            }
            if (a_chars.length < b_chars.length) {
                return -1;
            }
            return 0;
        }

        /**
         * Sets the major version part.
         *
         * @param major The major version part.
         *
         * @throws VersionParseError If the supplied major version is invalid.
         */
        public void set_major_version (string major) throws VersionParseError {
            if (!major_version_regex.match (major, GLib.RegexMatchFlags.ANCHORED)) {
                throw new VersionParseError.INVALID_SEMVER_IDENTIFIER (@"Invalid major version: \"$major\"");
            }
            this.major = major;
        }

        /**
         * Sets the minor version part.
         *
         * @param minor The minor version part.
         *
         * @throws VersionParseError If the supplied minor version is invalid.
         */
        public void set_minor_version (string minor) throws VersionParseError {
            if (!minor_version_regex.match (minor, GLib.RegexMatchFlags.ANCHORED)) {
                throw new VersionParseError.INVALID_SEMVER_IDENTIFIER (@"Invalid minor version: \"$minor\"");
            }
            this.minor = minor;
        }

        /**
         * Sets the patch version part.
         *
         * @param patch The patch version part.
         *
         * @throws VersionParseError If the supplied patch version is invalid.
         */
        public void set_patch_version (string patch) throws VersionParseError {
            if (!patch_version_regex.match (patch, GLib.RegexMatchFlags.ANCHORED)) {
                throw new VersionParseError.INVALID_SEMVER_IDENTIFIER (@"Invalid patch version: \"$patch\"");
            }
            this.patch = patch;
        }

        /**
         * Sets the prerelease identifier.
         *
         * @param prerelease The prerelease identifier.
         *
         * @throws VersionParseError If the supplied prerelease identifier is invalid.
         */
        public void set_prerelease_identifier (string? prerelease) throws VersionParseError {
            if (prerelease == null) {
                this.prerelease = null;
                return;
            }
            if (!prerelease_regex.match (prerelease, GLib.RegexMatchFlags.ANCHORED)) {
                string err = @"Invalid prerelease identifier: \"$prerelease\"";
                throw new VersionParseError.INVALID_SEMVER_IDENTIFIER (err);
            }
            this.prerelease = prerelease;
        }

        /**
         * Sets the build metadata identifier.
         *
         * @param build_metadata The build metadata identifier.
         *
         * @throws VersionParseError If the supplied build metadata identifier is invalid.
         */
        public void set_build_metadata_identifier (string? build_metadata) throws VersionParseError {
            if (build_metadata == null) {
                this.build_metadata = null;
                return;
            }
            if (!build_metadata_regex.match (build_metadata, GLib.RegexMatchFlags.ANCHORED)) {
                string err = @"Invalid build metadata identifier: \"$build_metadata\"";
                throw new VersionParseError.INVALID_SEMVER_IDENTIFIER (err);
            }
            this.build_metadata = build_metadata;
        }

        /**
         * Increments the major version part.
         */
        public void increment_major_version () {
            this.major = Util.large_number_addition (this.major, "1");
        }

        /**
         * Decrements the major version part. If the version part is already 0, it will be unchanged.
         *
         * @return The updated value of the version part.
         */
        public string decrement_major_version () {
            if (can_decrement (this.major)) {
                this.major = Util.large_number_subtraction (this.major, "1");
            }
            return this.major;
        }

        /**
         * Increments the minor version part.
         */
        public void increment_minor_version () {
            this.minor = Util.large_number_addition (this.minor, "1");
        }

        /**
         * Decrements the minor version part. If the version part is already 0, it will be unchanged.
         *
         * @return The updated value of the version part.
         */
        public string decrement_minor_version () {
            if (can_decrement (this.minor)) {
                this.minor = Util.large_number_subtraction (this.minor, "1");
            }
            return this.minor;
        }

        /**
         * Increments the patch version part.
         */
        public void increment_patch_version () {
            this.patch = Util.large_number_addition (this.patch, "1");
        }

        /**
         * Decrements the patch version part. If the version part is already 0, it will be unchanged.
         *
         * @return The updated value of the version part.
         */
        public string decrement_patch_version () {
            if (can_decrement (this.patch)) {
                this.patch = Util.large_number_subtraction (this.patch, "1");
            }
            return this.patch;
        }

        private bool can_decrement (string value) {
            // Check whether we're attempting to subtract from 0
            if (value.length == 1 && int.parse (value) == 0) {
                return false;
            }
            return true;
        }

        /**
         * Formats the {@link Version} object as a valid SemVer string.
         *
         * @return The valid SemVer string.
         */
        public string to_string () {
            var sb = new GLib.StringBuilder (@"$major$CORE_VERSION_DELIM$minor$CORE_VERSION_DELIM$patch");
            if (prerelease != null) {
                sb.append (@"$PRERELEASE_PREFIX$prerelease");
            }
            if (build_metadata != null) {
                sb.append (@"$BUILD_METADATA_PREFIX$build_metadata");
            }
            return sb.str;
        }

    }

}
