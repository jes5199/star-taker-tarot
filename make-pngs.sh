#!/bin/bash
set -e

mkdir -p pngs

echo "Converting singles to 1200 DPI PNGs..."
for pdf in singles/*.pdf; do
  name=$(basename "$pdf" .pdf)
  echo "  $name"
  pdftoppm -png -r 1200 -singlefile "$pdf" "pngs/$name"
done

echo "Done! $(ls pngs/*.png | wc -l) PNGs in pngs/"
