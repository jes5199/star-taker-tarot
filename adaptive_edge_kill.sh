#!/bin/bash
# adaptive_edge_kill.sh - Remove border remnants from a PBM bitmap
#
# The bottom edge of minor arcana scans often retains a remnant of the
# printed card border frame after cropping. This script detects it by
# scanning inward from the bottom: if it finds a band of dense black
# pixels (>40% of width) followed by a gap (<15%), that's a border line.
# If density stays high continuously (dark art), it leaves it alone.
#
# Top/left/right get a fixed 5px kill only.
#
# Usage: adaptive_edge_kill.sh input.pbm output.pbm

set -e
INPUT="$1"
OUTPUT="$2"
SCAN_DEPTH=30
DENSITY_THRESH=40  # percent to consider "dense"
GAP_THRESH=15      # percent to consider "gap"
GAP_ROWS=3         # consecutive gap rows needed to confirm border

W=$(identify -format '%w' "$INPUT")
H=$(identify -format '%h' "$INPUT")
MIN_DENSE=$((W * DENSITY_THRESH / 100))
MIN_GAP=$((W * GAP_THRESH / 100))

# Get per-row black pixel counts for bottom edge region
BOT_START=$((H - SCAN_DEPTH))
BOT_DATA=$(convert "$INPUT" -crop "${W}x${SCAN_DEPTH}+0+${BOT_START}" -depth 1 txt: 2>/dev/null \
    | grep "gray(0)" | cut -d, -f2 | cut -d: -f1 | sort -n | uniq -c)

# Build array: row_offset -> count
declare -A ROW_COUNT
while read count row; do
    [ -z "$row" ] && continue
    ROW_COUNT[$row]=$count
done <<< "$BOT_DATA"

# Scan from bottom edge inward
# State machine: look for dense band, then gap
BOT_KILL=-1
in_dense=false
dense_end=-1

for ((i=SCAN_DEPTH-1; i>=0; i--)); do
    count=${ROW_COUNT[$i]:-0}
    if [ "$count" -ge "$MIN_DENSE" ]; then
        if ! $in_dense; then
            in_dense=true
            dense_end=$i  # furthest from edge
        fi
    else
        if $in_dense && [ "$count" -lt "$MIN_GAP" ]; then
            # We exited a dense band into a gap - this was a border
            # Kill from bottom edge up to dense_end + 2px margin
            BOT_KILL=$((dense_end + 2))
            break
        fi
    fi
done

# If we're still in a dense band at the scan limit, it's continuous art - don't kill
if $in_dense && [ "$BOT_KILL" -lt 0 ]; then
    BOT_KILL=-1
fi

echo "  bottom border: kill=$BOT_KILL (dense band detected=$in_dense)"

# Apply: fixed 5px on top/left/right, adaptive on bottom
DRAW_ARGS="-draw \"rectangle 0,0 499,4\" -draw \"rectangle 0,0 4,877\" -draw \"rectangle 495,0 499,877\""

if [ "$BOT_KILL" -ge 0 ]; then
    BOT_ABS=$((H - 1 - BOT_KILL))
    DRAW_ARGS="$DRAW_ARGS -draw \"rectangle 0,$BOT_ABS $((W-1)),$((H-1))\""
else
    # Fallback: still kill 5px at bottom
    DRAW_ARGS="$DRAW_ARGS -draw \"rectangle 0,$((H-5)) $((W-1)),$((H-1))\""
fi

eval convert "$INPUT" -fill white $DRAW_ARGS "$OUTPUT"
