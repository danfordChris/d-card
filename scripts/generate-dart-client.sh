#!/usr/bin/env bash
# Regenerates dart_packages/dcard_api from packages/api-contract/openapi.json.
# Requires Docker. Run after any API contract change: `pnpm api:dart`.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="dart_packages/dcard_api"
GENERATOR_IMAGE="openapitools/openapi-generator-cli:v7.16.0"

pnpm --dir "$ROOT" --filter @dcard/api-contract openapi
rm -rf "$ROOT/$OUT"
docker run --rm -u "$(id -u):$(id -g)" -v "$ROOT:/local" "$GENERATOR_IMAGE" generate \
  -i /local/packages/api-contract/openapi.json \
  -g dart \
  -o "/local/$OUT" \
  --additional-properties=pubName=dcard_api,pubDescription="Generated D-Card API client (do not edit)",pubVersion=0.0.1,pubLibrary=dcard_api \
  --skip-validate-spec >/dev/null

# Make the generated package a member of the Dart pub workspace.
cd "$ROOT/$OUT"
rm -rf .travis.yml git_push.sh .openapi-generator-ignore test
python3 - <<'PY'
import re
p = "pubspec.yaml"
s = open(p).read()
s = re.sub(r"environment:\n(\s+sdk:.*\n)", "environment:\n  sdk: ^3.12.0\n", s)
s = s.replace("name: 'dcard_api'", "name: dcard_api")
s = re.sub(r"dev_dependencies:\n(\s+.*\n?)*", "", s)  # generated test deps conflict with the workspace
if "resolution: workspace" not in s:
    s = s.replace("environment:", "resolution: workspace\npublish_to: none\n\nenvironment:", 1)
open(p, "w").write(s)
open("analysis_options.yaml", "w").write("analyzer:\n  exclude:\n    - '**'\n")

# The generator asserts (debug builds only) that every required key is non-null, even for
# fields the contract marks nullable (OpenAPI 3.1 `type: [x, "null"]`, typed `T?` in Dart).
# That crashes debug builds on valid responses, so drop the null assertion; the presence
# check stays.
import glob
for f in glob.glob("lib/model/*.dart"):
    src = open(f).read()
    out = re.sub(r"\n[ \t]*assert\(json\[key\] != null, 'Required key \"[^\"]+\" has a null value in JSON\.'\);", "", src)
    if out != src:
        open(f, "w").write(out)
PY
echo "dcard_api generated in $OUT"
