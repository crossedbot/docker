## Docker wrapper for md-to-pdf and pdftk
A docker wrapper for md-to-pdf and pdftk to generate and merge a single PDF 
document from given markdown files.

### Build
`$ docker build -t md2pdf-do .`

### Run
`$ docker run --rm -v /path/to/:/path/to/ md2pdf-do -o /path/to/content.pdf /path/to/input.1.md /path/to/input.2.md`