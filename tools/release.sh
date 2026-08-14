#!/usr/bin/env bash
# release.sh — deterministic release build for sdd-canon.
#
#   bash tools/release.sh
#
# 1. Regenerates MANIFEST.sha256 over every content file (sorted, sha256sum
#    format — the same procedure the SDD kit's build-dist.sh uses).
# 2. Builds dist/sdd-canon-<VERSION>.zip deterministically: sorted entries,
#    fixed timestamp and permissions — rebuilding yields byte-identical output.
#
# The zip contains the manifest, so a consumer can verify offline:
#   unzip -q sdd-canon-<V>.zip -d x && (cd x && sha256sum -c MANIFEST.sha256)
#
# Publishing (manual by design — updates are a human act):
#   git tag -a v<VERSION> && git push --tags
#   gh release create v<VERSION> dist/sdd-canon-<VERSION>.zip MANIFEST.sha256
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
VERSION="$(tr -d '[:space:]' < VERSION)"

find . -type f ! -path './.git/*' ! -path './dist/*' ! -name 'MANIFEST.sha256' \
    -print0 | sort -z | xargs -0 sha256sum | sed 's|  \./|  |' > MANIFEST.sha256
echo "  manifest: $(wc -l < MANIFEST.sha256) files"

mkdir -p dist
python3 - "$VERSION" <<'PY'
import sys, zipfile
from pathlib import Path

version = sys.argv[1]
root = Path.cwd()
out = root / "dist" / f"sdd-canon-{version}.zip"
EXCLUDE = (".git", "dist")

files = sorted(
    p for p in root.rglob("*")
    if p.is_file() and not any(part in EXCLUDE for part in p.relative_to(root).parts)
)
with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as z:
    for p in files:
        rel = p.relative_to(root).as_posix()
        info = zipfile.ZipInfo(rel, date_time=(1980, 1, 1, 0, 0, 0))
        info.external_attr = (0o755 if p.suffix == ".sh" else 0o644) << 16
        z.writestr(info, p.read_bytes())
print(f"  zip: {out.name} ({out.stat().st_size} bytes, {len(files)} entries)")
PY
echo "  done: dist/sdd-canon-${VERSION}.zip"
