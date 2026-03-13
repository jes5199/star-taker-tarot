# Star Taker Tarot

## Build

Compile with lualatex (requires two passes for TOC page numbers):

```
lualatex -interaction=nonstopmode book.tex
```

## Pamphlet

Build the saddle-stitched pamphlet (prints on letter paper, fold and staple):

```
lualatex -interaction=nonstopmode pamphlet.tex
pdfbook2 --paper=letterpaper --short-edge pamphlet.pdf
```

Output: `pamphlet-book.pdf` — print duplex (short-edge flip), fold in half, staple.

## Preview

Start a webserver on port 8000 to browse the PDF:

```
python3 -m http.server 8000
```

Then open http://localhost:8000/book.pdf
