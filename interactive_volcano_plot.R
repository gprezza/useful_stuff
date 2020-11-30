library(plyr)
library(htmlwidgets)
library(htmltools)
library("plotly")

range01 <- function(x){(x-min(x))/(max(x)-min(x))}

make_volcanoPlot <- function(data_tab,FDRtresh,logFCtresh,url,plot_title){
  volcTable <- data_tab[c("genes", "logFC", "FDR")]
  # Group genes based on values:
  volcTable["group"] <- "other"
  significant <- sprintf("FDR < %s", FDRtresh)
  high_FC <- sprintf("|logFC| > %s", logFCtresh)
  sig_and_FC <- sprintf("|logFC| > %s and FDR < %s", logFCtresh, FDRtresh)
  volcTable[which(volcTable['FDR'] < FDRtresh & abs(volcTable['logFC']) < logFCtresh ),"group"] <- significant
  volcTable[which(volcTable['FDR'] > FDRtresh & abs(volcTable['logFC']) > logFCtresh ),"group"] <- high_FC
  volcTable[which(volcTable['FDR'] < FDRtresh & abs(volcTable['logFC']) > logFCtresh ),"group"] <- sig_and_FC
  # Find and label the top peaks:
  top_up <- volcTable[ which(volcTable$FDR < FDRtresh & volcTable$logFC >= logFCtresh),]
  if (length(rownames(top_up))>0){
    top_up$logFC.scaled <- range01(top_up$logFC)
    top_up$FDR.scaled <- range01(-log(top_up$FDR))
    top_up$sum <- (top_up$logFC.scaled + top_up$FDR.scaled)
    top_up <- top_up[order(-top_up$sum),][1:5,]
  }
  top_down <- volcTable[ which(volcTable$FDR < FDRtresh & volcTable$logFC <= -logFCtresh),]
  if (length(rownames(top_down))>0){
    top_down$logFC.scaled <- range01(-top_down$logFC)
    top_down$FDR.scaled <- range01(-log(top_down$FDR))
    top_down$sum <- (top_down$logFC.scaled + top_down$FDR.scaled)
    top_down <- top_down[order(-top_down$sum),][1:5,]
  }
  top_peaks <- rbind.fill(top_up, top_down)
  top_peaks <- na.omit(top_peaks)
  # Add gene labels for all of the top genes we found
  # here we are creating an empty list, and filling it with entries for each row in the dataframe
  # each list entry is another list with named items that will be used by Plot.ly
  ann <- list()
  for (i in seq_len(nrow(top_peaks))) {
    m <- top_peaks[i, ]
    ann[[i]] <- list(
      x = m[["logFC"]]+.03,
      y = -log10(m[["FDR"]])+.03,
      text = m[["genes"]],
      font = list(size = 14),
      xref = "x",
      yref = "y",
      showarrow = TRUE,
      arrowhead = 0.5,
      ax = 20,
      ay = -30
    )
  }
  # make the Plot.ly plot:
  pal <- c("#d16411", "blue", "#1adb44","black")
  pal <- setNames(pal, c(significant, high_FC, sig_and_FC,"other"))
  #function to add vertical line to the plot:
  vline <- function(x = 0, color = "grey") {list(type = "line", y0 = 0, y1 = 1, yref = "paper", x0 = x, x1 = x, line = list(color = color, width = 1, dash = 'dot'))}
  #make the plot:
  p <- plot_ly(data = volcTable, x = volcTable$logFC, y = -log10(volcTable$FDR), text = volcTable$genes, mode = "markers", color = ~volcTable$group, colors=pal,type = "scatter") %>%
    layout(title=list(text = plot_title, font = list(size = 20)))%>%
    layout(margin = list(t = 35))%>% #extends top margin to fit title
    layout(xaxis = list(title = "logFC",titlefont = list(size = 20)))%>%
    layout(yaxis = list(title = "-log<sub>10</sub>FDR",titlefont = list(size = 20)))%>%
    layout(hoverlabel = list(font=list(size=14)))%>% #font size of hover boxes
    layout(legend = list(font=list(size=16)))%>% #font size of legend
    layout(annotations = ann)%>%
    layout(shapes = list(vline(logFCtresh),vline(-logFCtresh)))%>%
    onRender("
                        function(el,x,data) {
                        el.on('plotly_click', function(d) {
                        if (typeof d.points[0].data.text == 'string') {
                                var gene_name = d.points[0].data.text;
                        } else {
                                var gene_name = d.points[0].data.text[d.points[0].pointNumber];
                        };
                        var full_url = data + gene_name;
                        window.open(full_url);
                        });
                        }
                        ", data=url)
  # add search box and button:
  p <- htmlwidgets::appendContent(p, htmltools::tags$input(id='inputText', value='Search gene', ''), htmltools::tags$button(id='buttonSearch', 'Search'))
  p <- htmlwidgets::appendContent(p, htmltools::tags$script(HTML(
    'document.getElementById("buttonSearch").addEventListener("click", function()
                    {
                      var i = 0;
                      var j = 0;
                      var found = [];
                      var myDiv = document.getElementsByClassName("js-plotly-plot")[0]
                      var data = JSON.parse(document.querySelectorAll("script[type=\'application/json\']")[0].innerHTML);
                      for (i = 0 ;i < data.x.data.length; i += 1) {
                        for (j = 0; j < data.x.data[i].text.length; j += 1) {
                          if (data.x.data[i].text[j].indexOf(document.getElementById("inputText").value) !== -1) {
                            found.push({curveNumber: i, pointNumber: j});
                          }
                        }
                      }
                      Plotly.Fx.hover(myDiv, found);
                    }
                  );')))
  # Save plot to a HTML file in the "plots" subfolder:
  f <- paste(plot_title,".html",sep="")
  withr::with_dir('plots', htmlwidgets::saveWidget(as_widget(p), file=f))
}

