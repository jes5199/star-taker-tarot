# Star Taker Tarot — build everything
# Usage: make          (build all PDFs)
#        make pngs     (build all PDFs + 1200 DPI PNGs)
#        make clean    (remove build artifacts)

# lualatex returns non-zero on non-fatal warnings, so we ignore its exit code
# and check for the output file instead
LUALATEX = lualatex -interaction=nonstopmode

# Shared dependencies
DEPS = cards-preamble.tex card-defs.tex

# Main targets
all: book.pdf cards.pdf singles.pdf dark.pdf print.pdf cardback.pdf pamphlet-book.pdf oracle-lunar.pdf pngs

# Book (requires two passes for TOC)
book.pdf: book.tex book-cards.tex $(DEPS)
	-$(LUALATEX) book.tex
	-$(LUALATEX) book.tex

# Cards (4-up sheets)
cards.pdf: cards.tex cards-body.tex $(DEPS)
	-$(LUALATEX) cards.tex

# Singles (one card per page)
singles.pdf: singles.tex singles-body.tex $(DEPS)
	-$(LUALATEX) singles.tex

# Dark background variant
dark.pdf: dark.tex cards-body.tex $(DEPS)
	-$(LUALATEX) dark.tex

# Print-ready version
print.pdf: print.tex print-body.tex $(DEPS)
	-$(LUALATEX) print.tex

# Card back
cardback.pdf: cardback.tex
	-$(LUALATEX) cardback.tex

# Pamphlet + booklet imposition
pamphlet.pdf: pamphlet.tex $(DEPS)
	-$(LUALATEX) pamphlet.tex

pamphlet-book.pdf: pamphlet.pdf
	pdfbook2 --paper=letterpaper --short-edge pamphlet.pdf

# Oracle, Lunar — 30 cards, one moon phase per page
oracle-lunar.pdf: oracle-lunar.tex $(DEPS)
	-$(LUALATEX) oracle-lunar.tex

# Individual card PDFs + PNGs
pngs: singles.pdf
	bash make-singles.sh
	bash make-pngs.sh

clean:
	rm -f *.aux *.log *.out *.toc *.synctex.gz

.PHONY: all pngs clean
