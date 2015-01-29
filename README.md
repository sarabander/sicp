SICP
====

<img src="http://sicpebook.files.wordpress.com/2013/09/smile0.png"
 alt="Par smiling" align="right" />

This is a new HTML5 and EPUB3 version of "Structure and Interpretation of Computer Programs" by Abelson, Sussman, and Sussman. It comes from the lineage of [Unofficial Texinfo Format](http://www.neilvandyke.org/sicp-texi/) that was converted from the original [HTML version](http://mitpress.mit.edu/sicp/) at The MIT Press.

<b>The book in EPUB3 format: [sicp.epub](https://www.dropbox.com/s/y9jt5kmabt02yg8/sicp.epub?dl=0)</b>

Modern solutions such as scalable vector graphics, mathematical markup with MathML and MathJax, embedded web fonts, and syntax highlighting are used. Rudimentary scaffolding for responsive design is in place, which adapts the page for viewing on pocket devices and tablets. More tests on small screens are needed to adjust the font size and formatting, so I encourage feedback from smartphone and tablet owners.

Source
------

The root directory contains the Texinfo source in `sicp-pocket.texi.` To recreate the HTML files and build EPUB, enter:

```bash
$ make
```

All the files in `html` directory, but not in subdirectories, will be overwritten, so the preferred place to make changes is `sicp-pocket.texi.` The EPUB file will be created in the parent directory, outside of the project tree.

You will need [Texinfo 5.1](http://ftp.gnu.org/gnu/texinfo/), Perl 5.12 or later, Ruby 1.9.3 or newer, [Nokogiri](http://nokogiri.org/) gem, [PhantomJS](http://phantomjs.org/), and Internet connection to compile the book.

Acknowledgements
----------------

* Lytha Ayth
* Neil Van Dyke
* Gavrie Philipson
* Li Xuanji
* J. E. Johnson
* Matt Iversen
* Eugene Sharygin

License
-------

The source file `sicp-pocket.texi,` HTML content of the book, and diagrams in directory `html/fig` are licensed under Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License ([cc by-nc-sa](http://creativecommons.org/licenses/by-nc-sa/3.0/)).
          
Most of the scripts are licensed under GNU General Public License version 3 (for details, see LICENSE.src).

Fonts are under SIL Open Font License version 1.1. Other files, like Javascript libraries, have their own licenses.

Sister project
--------------

A [PDF version](https://github.com/sarabander/sicp-pdf) built from LaTeX source accompanies this HTML version.
