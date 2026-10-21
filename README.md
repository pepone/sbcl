# SBCL binaries

This branch builds SBCL releases as relocatable binaries for a stated minimum system version. It holds no SBCL
source: each build downloads the release's source tarball, checks it against a pinned SHA-256, applies this branch's
patches and runs SBCL's tests before publishing.

The official macOS arm64 binary on sbcl.org stops at 2.4.0, and package managers build for the system they run on,
so their runtimes refuse to start on older macOS versions. These builds set `MACOSX_DEPLOYMENT_TARGET` and leave out
core compression, so the runtime links only the system's libraries.

| Target | Runner | Minimum |
| --- | --- | --- |
| macOS arm64 | `macos-15` | macOS 13.0 |

## Building a release

1. Add `versions/<version>.env` with the release's source tarball URL and SHA-256, and any patches the release
   needs under `patches/<version>/` (applied with `patch -p1`, in name order).
2. Push a tag `bin-<version>-<build>`, such as `bin-2.6.9-1`. The build number starts at 1 for each version and
   grows with every rebuild of it, such as a new patch; a published tag is never moved or reused.

The `Binaries` workflow builds the tag and publishes `sbcl-<version>-arm64-darwin-macos13.0-binary.tar.bz2` and its
`.sha256` as the tag's release. Install it with `INSTALL_ROOT=<prefix> sh install.sh` from the extracted directory.

## Patches

| Version | Patch | Source | Why |
| --- | --- | --- | --- |
| 2.6.9 | `revert-utf8-c-string-simd-regression.patch` | Homebrew's `sbcl` formula | arm64 miscompiled UTF-8 C string reads |
