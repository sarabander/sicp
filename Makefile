# Makefile for compiling sicp.epub from the sources.
# (c) 2014 Andres Raba, GNU GPL v.3.

# Constants

DIR = html/
SRC = sicp-pocket.texi          # book's Texinfo source
GOAL = ../sicp.epub             # the end product of compilation
NEXUS = $(DIR)index.xhtml       # the central file with table of contents
META = content.opf toc.xhtml    # epub metafiles generated from NEXUS
HTML = $(DIR)*.xhtml            # all the HTML files of the book
FIG = $(DIR)fig/*/*.svg         # SVG diagrams
CSS = $(DIR)css/*.css           # style files
FONT = $(DIR)css/fonts/*        # WOFF fonts
JS = $(DIR)js/*.js              # javascript libraries
CONV = texi2any lib/Texinfo/Convert/HTML.pm     # Texinfo converter scripts
MATH = get-math.js put-math.js mathcell.xhtml   # LaTeX -> MathML converter
HIGHL = $(DIR)js/highlight/
PRETTY = $(HIGHL)prettify.js $(HIGHL)lang-lisp.js batch-prettify.js
COVER = index.in.xhtml $(DIR)fig/coverpage.std.svg $(DIR)fig/bookwheel.jpg
THUMB = $(DIR)fig/cover.png     # thumbnail cover image
SHELL = /bin/bash

JQ = <script src=\"js/jquery.min.js\" type=\"text/javascript\"></script>
FT = <script src=\"js/footnotes.js\" type=\"text/javascript\"></script>
BR = <script src=\"js/browsertest.js\" type=\"text/javascript\"></script>

GITHUB = <a href=\"https://github.com/sarabander/sicp\"><img style=\"position: absolute; top: 0; right: 0; border: 0; width: 149px; height: 149px; z-index: 10; opacity: 0.5;\" src=\"http://aral.github.com/fork-me-on-github-retina-ribbons/right-red\@2x.png\" alt=\"Fork me on GitHub\" /></a>

# Targets

all: $(GOAL)
# Add scripts to the unpacked HTML5 version that is to be read in a browser.
	@if ! grep -m 1 -l 'browsertest' $(NEXUS); then \
	  for file in $(HTML); do \
	    perl -0p -i.bak -e \
	      "s{\s*</head>}{\n\n$(JQ)\n$(FT)\n$(BR)\n</head>}" $$file; \
	  done; \
	  rm $(DIR)*.bak; \
	fi; \
	perl -0p -i.bak -e \
	  "s{<!-- Fork me banner -->}{$(GITHUB)}" index.xhtml; \
	rm *.bak

html: $(NEXUS)

exercises.texi figures.texi: ex-fig-ref.pl
	@./ex-fig-ref.pl -e > exercises.texi; \
	 ./ex-fig-ref.pl -f > figures.texi

$(NEXUS): $(SRC) $(CONV) $(MATH) $(PRETTY) exercises.texi figures.texi
	@echo -n "Converting Texinfo file to HTML..."; \
	./texi2any --no-warn --html --split=section --no-headers --iftex $(SRC)
	@# Remove temporary files.
	@grep -lZ 'This file redirects' $(HTML) | xargs -0 rm -f --
	@echo "done."

	@echo -n "Replacing LaTeX with MathML..."; \
	./get-math.js db.json $(HTML); \
	./put-math.js db.json $(HTML); \
	echo "done."

	@echo -n "Syntax highlighting Scheme code..."; \
	./batch-prettify.js $(HTML); \
	echo "done."

	@# Add xml declaration
	@for file in $(HTML); do \
	  perl -0p -i -e \
	    's/^<!DOC/<?xml version="1.0" encoding="utf-8"?>\n<!DOC/' \
	    $$file; \
	done

	@# Fix broken link
	@perl -0p -i -e \
	  's{\.\./dir/index\.xhtml}{../index.xhtml}g' $(NEXUS)

epub: $(GOAL)

$(META): $(NEXUS) create_metafiles.rb 
	@echo -n "Building ePub3 file, saving to parent directory..."
	@# Remove 'xmlns:xml' attribute inserted by batch-prettify.
	@for file in $(HTML); do \
	  sed -i.bak "s/xmlns:xml[^ ]\+[ ]//" $$file; \
	done; \
	rm $(DIR)*.bak; \
	./create_metafiles.rb

$(THUMB): $(COVER)
	@inkscape $(DIR)fig/coverpage.std.svg -b "#fbfbfb" -C --export-filename=$(THUMB) > /dev/null

$(GOAL): $(META) $(THUMB) $(FIG) $(CSS) $(FONT) mimetype META-INF/* LICENSE
	@if [ -f $(GOAL) ]; then rm $(GOAL); fi; \
	if grep -q -m 1 -l 'browsertest' $(NEXUS); then \
	  for file in $(HTML); do \
	    perl -0p -i.bak -e \
	      "s{\n$(JQ)\n$(FT)\n$(BR)\n}{}" $$file; \
	  done; \
	  rm $(DIR)*.bak; \
	fi; \
	zip -0Xq $(GOAL) mimetype; \
	cp index.in.xhtml index.xhtml; \
	zip -Xr9Dq $(GOAL) $(META) $(HTML) META-INF/* LICENSE \
	  index.xhtml $(DIR)css/* $(DIR)fig/* ; \
	echo "done."

.PHONY: all epub html
