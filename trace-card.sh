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
#    then asymmetric crop to get inside the printed black card frame.
#    Top gets 25px (less, to preserve roman numerals near the border).
#    Bottom gets 45px (more, to fully remove the thicker bottom border).
#    Sides get 30px each.
echo "Cropping border..."
convert "$TMPDIR/source.jpg" \
    -fuzz 15% -trim +repage \
    -shave 20x20 +repage \
    -fuzz 15% -trim +repage \
    "$TMPDIR/trimmed.jpg"
TRIM_W=$(identify -format '%w' "$TMPDIR/trimmed.jpg")
TRIM_H=$(identify -format '%h' "$TMPDIR/trimmed.jpg")
CROP_W=$((TRIM_W - 60))
CROP_H=$((TRIM_H - 70))
convert "$TMPDIR/trimmed.jpg" -crop "${CROP_W}x${CROP_H}+30+25" +repage "$TMPDIR/cropped.jpg"

# 2. Extract red channel, resize, threshold to B&W bitmap
echo "Converting to B&W bitmap (red channel, threshold 35%)..."
convert "$TMPDIR/cropped.jpg" \
    -channel R -separate \
    -resize 500x878\! \
    -threshold 35% \
    "$TMPDIR/card.pbm"

# 2b. Adaptive edge kill: remove border remnants on all four edges.
#     For each edge, scans inward looking for a dense band followed by a
#     gap — that pattern indicates a border line. If density is continuous
#     (dark art extending to the edge), leaves it alone.
#     Top/bottom scan rows (40px depth, thresholds based on 500px width).
#     Right edge scans columns (20px depth, thresholds based on 878px height).
#     Left edge gets a fixed 5px kill (border rarely survives the crop there).
echo "Removing edge artifacts..."

# --- Helper: adaptive border scan ---
# Scans a 1D density profile from the edge inward.
# Prints the kill depth, or -1 if no border detected.
adaptive_kill() {
    local -n COUNTS=$1
    local depth=$2
    local min_dense=$3
    local min_gap=$4
    local direction=$5  # "from_end" or "from_start"

    local kill=-1 in_dense=false last_dense=-1
    if [ "$direction" = "from_end" ]; then
        for ((i=depth-1; i>=0; i--)); do
            local c=${COUNTS[$i]:-0}
            if [ "$c" -ge "$min_dense" ]; then
                in_dense=true; last_dense=$i
            elif $in_dense && [ "$c" -lt "$min_gap" ]; then
                kill=$((depth - 1 - last_dense + 2)); break
            fi
        done
    else
        for ((i=0; i<depth; i++)); do
            local c=${COUNTS[$i]:-0}
            if [ "$c" -ge "$min_dense" ]; then
                in_dense=true; last_dense=$i
            elif $in_dense && [ "$c" -lt "$min_gap" ]; then
                kill=$((last_dense + 2)); break
            fi
        done
    fi
    if $in_dense && [ "$kill" -lt 0 ]; then kill=-1; fi
    echo "$kill"
}

# --- Bottom edge (row scan, 40px depth) ---
H_SCAN=40
H_DENSE=$((500 * 40 / 100))
H_GAP=$((500 * 15 / 100))

BOT_START=$((878 - H_SCAN))
BOT_DATA=$(convert "$TMPDIR/card.pbm" -crop "500x${H_SCAN}+0+${BOT_START}" -depth 1 txt: 2>/dev/null \
    | grep "gray(0)" | cut -d, -f2 | cut -d: -f1 | sort -n | uniq -c)
declare -A BOT_ROW
while read count row; do [ -z "$row" ] && continue; BOT_ROW[$row]=$count; done <<< "$BOT_DATA"
BOT_KILL=$(adaptive_kill BOT_ROW $H_SCAN $H_DENSE $H_GAP from_end)

# --- Top edge (row scan, 40px depth) ---
TOP_DATA=$(convert "$TMPDIR/card.pbm" -crop "500x${H_SCAN}+0+0" -depth 1 txt: 2>/dev/null \
    | grep "gray(0)" | cut -d, -f2 | cut -d: -f1 | sort -n | uniq -c)
declare -A TOP_ROW
while read count row; do [ -z "$row" ] && continue; TOP_ROW[$row]=$count; done <<< "$TOP_DATA"
TOP_KILL=$(adaptive_kill TOP_ROW $H_SCAN $H_DENSE $H_GAP from_start)

# --- Right edge (peak detection, 20px depth) ---
# Gap detection fails here because some cards have dense art (70%+) that
# merges with the border. Instead, find the innermost column with >85%
# density (the border peak) and kill from there to the edge with margin.
V_SCAN=20
PEAK_THRESH=$((878 * 85 / 100))

RIGHT_START=$((500 - V_SCAN))
RIGHT_DATA=$(convert "$TMPDIR/card.pbm" -crop "${V_SCAN}x878+${RIGHT_START}+0" -depth 1 txt: 2>/dev/null \
    | grep "gray(0)" | sed 's/,.*//' | sort -n | uniq -c)
declare -A RIGHT_COL
while read count col; do [ -z "$col" ] && continue; RIGHT_COL[$col]=$count; done <<< "$RIGHT_DATA"

# Find innermost column with >85% density (border peak)
innermost_peak=-1
for ((i=0; i<V_SCAN; i++)); do
    if [ "${RIGHT_COL[$i]:-0}" -ge "$PEAK_THRESH" ]; then
        innermost_peak=$i
        break
    fi
done
if [ "$innermost_peak" -ge 0 ]; then
    RIGHT_KILL=$((V_SCAN - innermost_peak + 2))
else
    RIGHT_KILL=-1
fi

# --- Apply ---
DRAW_ARGS="-draw \"rectangle 0,0 4,877\""
if [ "$TOP_KILL" -ge 0 ]; then
    DRAW_ARGS="$DRAW_ARGS -draw \"rectangle 0,0 499,$TOP_KILL\""
else
    DRAW_ARGS="$DRAW_ARGS -draw \"rectangle 0,0 499,4\""
fi
if [ "$BOT_KILL" -ge 0 ]; then
    BOT_ABS=$((878 - 1 - BOT_KILL))
    DRAW_ARGS="$DRAW_ARGS -draw \"rectangle 0,$BOT_ABS 499,877\""
else
    DRAW_ARGS="$DRAW_ARGS -draw \"rectangle 0,873 499,877\""
fi
if [ "$RIGHT_KILL" -ge 0 ]; then
    RIGHT_ABS=$((500 - 1 - RIGHT_KILL))
    DRAW_ARGS="$DRAW_ARGS -draw \"rectangle $RIGHT_ABS,0 499,877\""
else
    DRAW_ARGS="$DRAW_ARGS -draw \"rectangle 495,0 499,877\""
fi
eval convert "$TMPDIR/card.pbm" -fill white $DRAW_ARGS "$TMPDIR/card.pbm"

# 3. Trace with potrace
echo "Tracing with potrace..."
potrace -s --flat "$TMPDIR/card.pbm" -o "$DIR/${PREFIX}.svg"

# 4. Generate PDF
echo "Generating PDF..."
convert "$DIR/${PREFIX}.svg" "$DIR/${PREFIX}.pdf"

echo "Done: images/${PREFIX}.svg and images/${PREFIX}.pdf"
