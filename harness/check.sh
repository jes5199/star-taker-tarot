#!/bin/bash
# Render-identity harness for the .tex reorg.
#
# lualatex is byte-reproducible when SOURCE_DATE_EPOCH is set (verified by
# building cardback.pdf and cards.pdf twice and hashing), so we force-rebuild
# every lualatex PDF target and sha256-compare against the committed baseline.
#
# pdfbook2 (pamphlet-book.pdf) embeds a wall-clock /CreationDate and ignores
# SOURCE_DATE_EPOCH, so that one target is compared by rasterizing every page
# with pdftoppm at 150 DPI and hashing the page images.
#
# Usage:
#   harness/check.sh            # rebuild all PDFs, compare to baselines
#   harness/check.sh --update   # rebuild and (re)write the baselines
set -u
cd "$(dirname "$0")/.."

export SOURCE_DATE_EPOCH=0
export FORCE_SOURCE_DATE=1

BYTE_TARGETS="book.pdf cards.pdf singles.pdf dark.pdf print.pdf cardback.pdf pamphlet.pdf oracle-lunar.pdf"
RASTER_TARGETS="pamphlet-book.pdf"

# -B: always rebuild, so stale PDFs can never produce a false green.
make -B $BYTE_TARGETS $RASTER_TARGETS >harness/build.log 2>&1
for t in $BYTE_TARGETS $RASTER_TARGETS; do
  if [ ! -f "$t" ]; then
    echo "HARNESS RED: $t was not produced (see harness/build.log)"
    exit 1
  fi
done

raster_manifest() {
  local out=$1
  : > "$out"
  local rasterdir
  rasterdir=$(mktemp -d)
  for t in $RASTER_TARGETS; do
    pdftoppm -r 150 -png "$t" "$rasterdir/$(basename "$t" .pdf)"
    for img in "$rasterdir"/*.png; do
      echo "$(sha256sum <"$img" | cut -d' ' -f1)  $t:$(basename "$img")" >> "$out"
    done
    rm -f "$rasterdir"/*.png
  done
  rmdir "$rasterdir"
}

if [ "${1:-}" = "--update" ]; then
  sha256sum $BYTE_TARGETS > harness/baseline.sha256
  raster_manifest harness/baseline-raster.sha256
  echo "baselines updated"
  exit 0
fi

status=0
sha256sum -c harness/baseline.sha256 || status=1
raster_manifest harness/current-raster.sha256
if diff -u harness/baseline-raster.sha256 harness/current-raster.sha256; then
  echo "raster targets: OK"
else
  status=1
fi

if [ $status -eq 0 ]; then
  echo "HARNESS GREEN: all PDFs render-identical to baseline"
else
  echo "HARNESS RED: output differs from baseline"
fi
exit $status
