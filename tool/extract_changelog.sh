#!/usr/bin/env bash
# Prints the notes under "## <version+build>" in CHANGELOG.md.
# Exits 1 if the section is missing or empty (so a release can't go out blank).
#   tool/extract_changelog.sh 1.3.0+8
set -euo pipefail
v="${1:?usage: extract_changelog.sh <version+build>}"
file="${CHANGELOG:-CHANGELOG.md}"
notes="$(awk -v h="## $v" '$0 == h { found = 1; next } /^## / { found = 0 } found' "$file")"
if [ -z "$(printf '%s' "$notes" | tr -d '[:space:]')" ]; then
  echo "CHANGELOG.md has no (or an empty) section '## $v'. Add one before tagging." >&2
  exit 1
fi
printf '%s\n' "$notes" | sed -e '/./,$!d'
