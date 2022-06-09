/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com> (https://avojak.com)
 */

namespace SemVer {

    private const uint SPEC_MAJOR_VERSION = 2;
    private const uint SPEC_MINOR_VERSION = 0;
    private const uint SPEC_PATCH_VERSION = 0;

    /**
     * Returns the major version of the SemVer specification.
     */
    public uint get_spec_major_version () {
        return SPEC_MAJOR_VERSION;
    }

    /**
     * Returns the minor version of the SemVer specification.
     */
    public uint get_spec_minor_version () {
        return SPEC_MINOR_VERSION;
    }

    /**
     * Returns the patch version of the SemVer specification.
     */
    public uint get_spec_patch_version () {
        return SPEC_PATCH_VERSION;
    }

}
