TEXFILE = main.tex

.PHONY: all clean

all:
	@lualatex --shell-escape $(TEXFILE)

clean:
	@rm -f main.pdf
	@find . -type f -name '*.aux' -delete
	@find . -type f -name '*.log' -delete
	@find . -type f -name '*.out' -delete
	@find . -type f -name '*.toc' -delete
	@find . -type f -name '*.fdb_latexmk' -delete
	@find . -type f -name '*.fls' -delete
	@find . -type f -name '*.synctex.gz' -delete
	@find . -type d -name 'svg-inkscape' -exec rm -rf {} +
