# useful_stuff
Random scripts/config files that do useful things and that took me way too long to make/find on the internet.

## [interactive_volcano_plot.R](https://github.com/gprezza/useful_stuff/blob/main/interactive_volcano_plot.R)
R script to do interactive volcano plots with plotly, saved as an html file in the current directory. The input *data_tab* table must contain a *locus_tab* column with gene names, a *FDR* one with FDR values and a *logFC* with the log2FC. Vertical lines at *logFCtresh* and -*logFCtresh* are drawn. *title* is the title given to the plot and the saved file.
- Clicking on a point opens a new tab to a pre-defined link to which the gene locus tag is attached. E.g. if url is *htt<span>ps://www</span>.ncbi.nlm.nih.gov/protein/?term=txid226186[Organism%3Anoexp]%20AND%20*, the page opens on the NCBI database page of the searched locus tag.
- Genes can be searched in a search field at the bottom left. Matched genes are colored and added to the legend. A custom name for the legend can be put before a colon in the search field (e.g. groEL:BT_1829). Multiple genes can be searched when separated by a comma (e.g. operon:BT_0074,BT_0073,BT_0072). If no custom name is given, the legend entry name is the search term.

## [.tmux.conf](https://github.com/gprezza/useful_stuff/blob/main/.tmux.conf)
Config file for tmux.

## [Resize_multiple_objects.js](https://github.com/gprezza/useful_stuff/blob/main/Resize_multiple_objects.js)
javascript macro for CorelDraw to resize all objects in the current selection, while maintaining their relative position. The scaling factor is set in the first line.
