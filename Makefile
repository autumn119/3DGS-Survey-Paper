# ============================================================
# Makefile — 3DGS Survey Paper compilation script
# 用法:
#   make 
#   make clean
#   make cleanall 
#   make view 
# ============================================================

TEX      = main
LATEX    = pdflatex
BIBTEX   = bibtex
VIEWER   = open    # macOS: open / Windows: start / Linux: xdg-open

.PHONY: all clean cleanall view

all: $(TEX).pdf

$(TEX).pdf: $(TEX).tex
	$(LATEX) -interaction=nonstopmode $(TEX)
	$(BIBTEX) $(TEX)
	$(LATEX) -interaction=nonstopmode $(TEX)
	$(LATEX) -interaction=nonstopmode $(TEX)

view: $(TEX).pdf
	$(VIEWER) $(TEX).pdf

clean:
	rm -f *.aux *.log *.out *.bbl *.blg *.synctex.gz
	rm -f *.fls *.fdb_latexmk *.toc *.lof *.lot
	rm -f *.nav *.snm *.vrb *.idx *.ilg *.ind
	rm -f *.bcf *.run.xml *.xml *.xdv *.dvi

cleanall: clean
	rm -f *.pdf
