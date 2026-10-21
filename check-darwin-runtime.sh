#!/bin/sh
# Usage: check-darwin-runtime.sh RUNTIME MINIMUM
#
# Fails unless RUNTIME, a Mach-O executable, targets macOS MINIMUM exactly and links only libraries macOS provides,
# so the binary starts on that version without anything else installed.
set -eu

runtime="$1"
minimum="$2"

minos=$(otool -l "$runtime" | awk '/LC_BUILD_VERSION/ { found = 1 } found && $1 == "minos" { print $2; exit }')
if [ "$minos" != "$minimum" ]; then
  echo "error: $runtime targets macOS ${minos:-unknown}, not $minimum" >&2
  exit 1
fi

others=$(otool -L "$runtime" | tail -n +2 | awk '{ print $1 }' | grep -v -e '^/usr/lib/' -e '^/System/Library/' || true)
if [ -n "$others" ]; then
  echo "error: $runtime links libraries outside the system:" >&2
  echo "$others" >&2
  exit 1
fi

echo "$runtime: macOS $minos, system libraries only"
