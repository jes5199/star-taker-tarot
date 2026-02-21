#!/bin/bash
# trace-card.sh - Convert a Wikimedia RWS tarot card image to B&W SVG+PDF
#
# Usage: ./trace-card.sh <url-or-file> <output-prefix>
# Example: ./trace-card.sh https://upload.wikimedia.org/.../RWS_Tarot_04_Emperor.jpg a-04
#          ./trace-card.sh my_scan.jpg c-09

set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 <url-or-file> <output-prefix>"
    echo "  url-or-file: Wikimedia URL or local JPG path"
    echo "  output-prefix: e.g. a-04, c-09, s-11 (outputs to images/)"
    exit 1
fi

INPUT="$1"
PREFIX="$2"
DIR="$(cd "$(dirname "$0")" && pwd)/images"
SRCDIR="$DIR/sources"
mkdir -p "$SRCDIR"
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

# Download or copy source (cache in images/sources/)
if [[ "$INPUT" == http* ]]; then
    CACHED="$SRCDIR/${PREFIX}.jpg"
    if [ -f "$CACHED" ]; then
        echo "Using cached $CACHED"
        cp "$CACHED" "$TMPDIR/source.jpg"
    else
        echo "Downloading $INPUT ..."
        wget -q --user-agent="Mozilla/5.0 (tarot-tracer)" "$INPUT" -O "$TMPDIR/source.jpg"
        cp "$TMPDIR/source.jpg" "$CACHED"
    fi
else
    cp "$INPUT" "$TMPDIR/source.jpg"
fi

# 1. Crop border: trim white margin, shave scan border, trim remainder,
#    then shave 45 to get inside the printed black card frame
echo "Cropping border..."
convert "$TMPDIR/source.jpg" \
    -fuzz 15% -trim +repage \
    -shave 20x20 +repage \
    -fuzz 15% -trim +repage \
    -shave 45x45 +repage \
    "$TMPDIR/cropped.jpg"

# 2. Extract red channel, resize, threshold to B&W bitmap
echo "Converting to B&W bitmap (red channel, threshold 35%)..."
convert "$TMPDIR/cropped.jpg" \
    -channel R -separate \
    -resize 500x878\! \
    -threshold 35% \
    "$TMPDIR/card.pbm"

# 2b. Adaptive edge kill: remove bottom border remnants
#     Scans inward from bottom edge looking for a dense band (>40% black)
#     followed by a gap (<15% black) — that pattern indicates a border line.
#     If black density is continuous (dark art), leaves it alone.
#     Top/left/right get a fixed 5px kill.
echo "Removing edge artifacts..."
SCAN_DEPTH=30
DENSITY_THRESH=40
GAP_THRESH=15
MIN_DENSE=$((500 * DENSITY_THRESH / 100))
MIN_GAP=$((500 * GAP_THRESH / 100))

BOT_START=$((878 - SCAN_DEPTH))
BOT_DATA=$(convert "$TMPDIR/card.pbm" -crop "500x${SCAN_DEPTH}+0+${BOT_START}" -depth 1 txt: 2>/dev/null \
    | grep "gray(0)" | cut -d, -f2 | cut -d: -f1 | sort -n | uniq -c)

declare -A ROW_COUNT
while read count row; do
    [ -z "$row" ] && continue
    ROW_COUNT[$row]=$count
done <<< "$BOT_DATA"

BOT_KILL=-1
in_dense=false
last_dense=-1
for ((i=SCAN_DEPTH-1; i>=0; i--)); do
    count=${ROW_COUNT[$i]:-0}
    if [ "$count" -ge "$MIN_DENSE" ]; then
        in_dense=true
        last_dense=$i  # tracks furthest dense row from edge
    else
        if $in_dense && [ "$count" -lt "$MIN_GAP" ]; then
            # Exited a dense band into a clear gap — it was a border
            BOT_KILL=$((last_dense + 2))
            break
        fi
    fi
done
if $in_dense && [ "$BOT_KILL" -lt 0 ]; then
    BOT_KILL=-1  # continuous dark art, don't kill
fi

DRAW_ARGS="-draw \"rectangle 0,0 499,4\" -draw \"rectangle 0,0 4,877\" -draw \"rectangle 495,0 499,877\""
if [ "$BOT_KILL" -ge 0 ]; then
    BOT_ABS=$((878 - 1 - BOT_KILL))
    DRAW_ARGS="$DRAW_ARGS -draw \"rectangle 0,$BOT_ABS 499,877\""
else
    DRAW_ARGS="$DRAW_ARGS -draw \"rectangle 0,873 499,877\""
fi
eval convert "$TMPDIR/card.pbm" -fill white $DRAW_ARGS "$TMPDIR/card.pbm"

# 3. Trace with potrace
echo "Tracing with potrace..."
potrace -s --flat "$TMPDIR/card.pbm" -o "$DIR/${PREFIX}.svg"

# 4. Generate PDF
echo "Generating PDF..."
convert "$DIR/${PREFIX}.svg" "$DIR/${PREFIX}.pdf"

echo "Done: images/${PREFIX}.svg and images/${PREFIX}.pdf"
