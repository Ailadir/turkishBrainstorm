#!/usr/bin/env bash
# Tiny tests for the release scripts. Run in CI.
set -uo pipefail
cd "$(dirname "$0")/.."
export CHANGELOG=tool/fixtures/CHANGELOG.sample.md
fail=0
ok()   { echo "ok   $1"; }
bad()  { echo "FAIL $1"; fail=1; }

out="$(tool/extract_changelog.sh 1.3.0+8)" && [ "$(printf '%s\n' "$out" | wc -l | tr -d ' ')" = "2" ] \
  && ok "finds a section" || bad "finds a section"
tool/extract_changelog.sh 9.9.9+1 >/dev/null 2>&1 && bad "missing section fails" || ok "missing section fails"
tool/extract_changelog.sh 1.2.0+7 >/dev/null 2>&1 && bad "empty section fails" || ok "empty section fails"

cur="v$(grep -m1 '^version:' pubspec.yaml | awk '{print $2}')"
tool/check_release_version.sh "$cur" && ok "matching tag passes" || bad "matching tag passes"
tool/check_release_version.sh v0.0.0+0 >/dev/null 2>&1 && bad "wrong tag fails" || ok "wrong tag fails"
exit $fail
