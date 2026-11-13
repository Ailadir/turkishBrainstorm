#!/usr/bin/env bash
# Checks that the git tag equals "v" + the version in pubspec.yaml.
#   tool/check_release_version.sh v1.3.0+8
set -euo pipefail
tag="${1:?usage: check_release_version.sh <tag>}"
want="v$(grep -m1 '^version:' pubspec.yaml | awk '{print $2}')"
if [ "$tag" != "$want" ]; then
  echo "Tag $tag does not match pubspec.yaml version ($want). Bump pubspec.yaml or fix the tag." >&2
  exit 1
fi
