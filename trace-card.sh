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

# 2b. Kill any remaining border pixels (white-out edges of bitmap)
#     20px top/bottom to catch border remnants, 5px left/right
convert "$TMPDIR/card.pbm" \
    -fill white \
    -draw "rectangle 0,0 499,19" \
    -draw "rectangle 0,858 499,877" \
    -draw "rectangle 0,0 4,877" \
    -draw "rectangle 495,0 499,877" \
    "$TMPDIR/card.pbm"

# 3. Trace with potrace
echo "Tracing with potrace..."
potrace -s --flat "$TMPDIR/card.pbm" -o "$DIR/${PREFIX}.svg"

# 4. Generate PDF
echo "Generating PDF..."
convert "$DIR/${PREFIX}.svg" "$DIR/${PREFIX}.pdf"

echo "Done: images/${PREFIX}.svg and images/${PREFIX}.pdf"
