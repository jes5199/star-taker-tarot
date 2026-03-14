# Star Taker Tarot

## Build

Build everything:

```
make          # all PDFs
make pngs     # all PDFs + individual card PNGs at 1200 DPI
make clean    # remove build artifacts
```

Or build individual targets:

```
make book.pdf          # book (two lualatex passes for TOC)
make cards.pdf         # 4-up card sheets
make singles.pdf       # one card per page
make dark.pdf          # dark background variant
make print.pdf         # print-ready version
make cardback.pdf      # card back
make pamphlet-book.pdf # saddle-stitched pamphlet booklet
```

The pamphlet booklet (`pamphlet-book.pdf`) prints duplex on letter paper (short-edge flip), fold in half, staple.

## Preview

Start a webserver on port 8000 to browse the PDF:

```
python3 -m http.server 8000
```

Then open http://localhost:8000/book.pdf

## Gotchas

### Scaling cards

Cards are rendered via `\resizebox{!}{HEIGHT}{\cardXxx}`. The card internals use absolute coordinates (`\cardwidth`, `\cardheight`), so `\resizebox` handles scaling cleanly. Do NOT try to scale by changing `\cardwidth`/`\cardheight` or wrapping in a `\scalebox` inside the card definition — that breaks line widths and font sizes. Always scale from the outside with `\resizebox`.

For TikZ diagrams containing cards, use `[scale=N, every node/.style={scale=N}]` on the tikzpicture to scale the whole diagram uniformly.

### Chinese characters not printing

The deck uses two Chinese fonts: `\cjkfont` (AR PL KaitiM Big5) for traditional Chinese and `\cjkfontgb` (AR PL KaitiM GB) for simplified. Big5 does not include simplified characters — if a glyph is missing, it will silently not render. Common culprits in solar term names: 处→處, 惊→驚, 蛰→蟄, 满→滿, 种→種. Always use traditional characters with `\cjkfont`.

### RTL languages (Hebrew, Arabic)

LuaLaTeX does not automatically handle right-to-left rendering. Single characters display fine, but multi-character strings will appear reversed. The fix:

- `\usepackage{luabidi}` is loaded in `cards-preamble.tex`
- Wrap multi-character Hebrew in `\RLE{}` (e.g., `\RLE{רוח}`)
- Arabic uses `\beginR...\endR` blocks via `\kufifont`

The `Script=Hebrew` / `Script=Arabic` font options handle glyph shaping but NOT bidi ordering — `luabidi` is required for that.
