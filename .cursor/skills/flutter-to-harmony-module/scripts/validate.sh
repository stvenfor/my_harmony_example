#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$SKILL_DIR/../../.." && pwd)"

SKILL_MD="$SKILL_DIR/SKILL.md"
TEMPLATE_MD="$SKILL_DIR/assets/template.md"
MAPPINGS_DIR="$SKILL_DIR/mappings"

fail() {
  echo "[FAIL] $1" >&2
  exit 1
}

pass() {
  echo "[PASS] $1"
}

echo "Validating flutter-to-harmony-module skill..."

[[ -f "$SKILL_MD" ]] || fail "Missing SKILL.md"
[[ -s "$SKILL_MD" ]] || fail "SKILL.md is empty"
[[ -f "$TEMPLATE_MD" ]] || fail "Missing assets/template.md"
[[ -s "$TEMPLATE_MD" ]] || fail "assets/template.md is empty"

grep -q "^---" "$SKILL_MD" || fail "SKILL.md missing YAML frontmatter"
grep -q "name: flutter-to-harmony-module" "$SKILL_MD" || fail "SKILL.md missing/incorrect name"
grep -q "ArkTS" "$SKILL_MD" || fail "SKILL.md should mention ArkTS"
grep -q "AGENTS.md" "$SKILL_MD" || fail "SKILL.md should require AGENTS.md"
grep -q "pagesMap" "$SKILL_MD" || fail "SKILL.md should mention pagesMap"
grep -q "mappings/09_flutter_breakpoints_to_harmony.md" "$SKILL_MD" || fail "SKILL.md should link to 09 breakpoints mapping"
pass "SKILL.md checks passed"

grep -q "Mapping Tables" "$TEMPLATE_MD" || fail "template missing mapping section"
grep -q "Route Registration" "$TEMPLATE_MD" || fail "template missing route section"
grep -q "Delivery Checklist" "$TEMPLATE_MD" || fail "template missing delivery section"
pass "template.md checks passed"

[[ -d "$MAPPINGS_DIR" ]] || fail "mappings/ directory missing"
for n in 01 02 03 04 05 06 07 08 09 10; do
  found="$(find "$MAPPINGS_DIR" -maxdepth 1 -name "${n}_*.md" | wc -l | tr -d ' ')"
  [[ "$found" -eq 1 ]] || fail "Expected exactly one mappings/${n}_*.md"
done
[[ -f "$MAPPINGS_DIR/README.md" ]] || fail "mappings/README.md missing"
pass "mappings/ 01–10 + README present"

[[ -f "$REPO_ROOT/AGENTS.md" ]] || fail "Repository AGENTS.md not found"
[[ -f "$REPO_ROOT/build-profile.json5" ]] || fail "build-profile.json5 not found"
[[ -f "$REPO_ROOT/common/src/main/ets/api/request.ets" ]] || fail "common request.ets not found"
[[ -f "$REPO_ROOT/entry/src/main/ets/pages/pagesMap.ets" ]] || fail "pagesMap.ets not found"
pass "Repository reference checks passed"

echo "All validations passed."
