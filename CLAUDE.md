# Star Taker Tarot

## Build

Compile with lualatex (requires two passes for TOC page numbers):

```
lualatex -interaction=nonstopmode book.tex
```

## Preview

Start a webserver on port 8000 to browse the PDF:

```
python3 -m http.server 8000
```

Then open http://localhost:8000/book.pdf
