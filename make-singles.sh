#!/bin/bash
set -e

echo "Compiling singles.tex (pass 1)..."
lualatex singles.tex
echo "Compiling singles.tex (pass 2)..."
lualatex singles.tex

mkdir -p singles

echo "Splitting into individual pages..."
pdfseparate singles.pdf singles/page-%d.pdf

# Card names in page order (79 cards)
names=(
  a-00 a-01 a-02 a-03 a-04 a-05 a-06 a-07 a-08 a-09
  a-10 a-11 a-12 a-13 a-14 a-15 a-16 a-17 a-18 a-19
  a-20 a-21
  w-01 c-01 s-01 p-01
  w-02 c-02 s-02 p-02
  w-03 c-03 s-03 p-03
  w-04 c-04 s-04 p-04
  w-05 c-05 s-05 p-05
  w-06 c-06 s-06 p-06
  w-07 c-07 s-07 p-07
  w-08 c-08 s-08 p-08
  w-09 c-09 s-09 p-09
  w-10 c-10 s-10 p-10
  w-11 c-11 s-11 p-11
  w-12 c-12 s-12 p-12
  w-13 c-13 s-13 p-13
  w-14 c-14 s-14 p-14
  card-back
)

echo "Renaming pages..."
for i in "${!names[@]}"; do
  page=$((i + 1))
  mv "singles/page-${page}.pdf" "singles/${names[$i]}.pdf"
done

echo "Done! $(ls singles/*.pdf | wc -l) cards in singles/"
