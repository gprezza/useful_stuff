library("plotly")
library(htmlwidgets)
library(htmltools)

vline <- function(x = 0, color = "grey") {
  list(type = "line", y0 = 0, y1 = 1, yref = "paper", x0 = x, x1 = x, line = list(color = color, width = 1, dash = 'dot'))
} #function to draw vertical line

interactive_volcano_plot <-function(data_tab, logFCtresh, url, title){
  #make the base plot:
  p = plot_ly(data = data_tab, 
              x = ~logFC, y = ~-log10(FDR),
              # control of marker properties (size and border color):
              type = "scatter",mode = "markers",
              height = 1000, text = ~locus_tag,
              marker = list(size = 15,
                            color = "#bbbbbb",
                            line = list(width = 1, color = "#424242"),
                            opacity=0.7)
  ) %>%
    layout(title=list(text = sub("\n","",title), font = list(size = 20)))%>% #add title
    layout(margin = list(t = 35))%>% #extends top margin to fit title
    layout(xaxis = list(title = "logFC",titlefont = list(size = 20)))%>%
    layout(yaxis = list(title = "-log<sub>10</sub>FDR",titlefont = list(size = 20)))%>%
    layout(hoverlabel = list(font=list(size=14)))%>% #font size of hover boxes
    layout(legend = list(font=list(size=16)))%>% #font size of legend
    layout(shapes = list(vline(logFCtresh),vline(-logFCtresh)))%>% #add vertical lines
    onRender( #function to open url+gene_name when clicking on a data point:
      "function(el,x,data) {
        el.on('plotly_click', function(d) {
          if (typeof d.points[0].data.text == 'string') {
            var gene_name = d.points[0].data.text;
          } else {
          var gene_name = d.points[0].data.text[d.points[0].pointNumber];
          };
          var full_url = data + gene_name;
          window.open(full_url);
        }
        );
       }", data=url)
  # add search box and button:
  p = htmlwidgets::appendContent(p, htmltools::tags$input(id='inputText', value='Gene name', ''), htmltools::tags$button(id='buttonSearch', 'Search'))
  # function to color datapoints matching searched text:
  p = htmlwidgets::appendContent(p, htmltools::tags$script(HTML(
    '
    var colors = ["#0077bb", "#009988", "#ee7733", "#cc3311", "#33bbee"];
    // Define the function for performing the search and coloring matching points
    function performSearch() {
      var j = 0; // point number
      // get current plot
      var myDiv = document.getElementsByClassName("js-plotly-plot")[0];
      // remove legend entry of base trace
      myDiv.data[0]["showlegend"] = false
      // add legend
      var update = {showlegend: true};
      Plotly.relayout(myDiv, update);
      // get data of the plot
      var data = JSON.parse(
        document.querySelectorAll(\'script[type="application/json"]\')[0].innerHTML);
      // Get the text entered in the input field
      var searchTerms = document.getElementById("inputText").value;
      // Get the name of the gene(s) group
      if (searchTerms.includes(":")){
        var searchTerms = searchTerms.split(":");
        var traceName = searchTerms[0]; // get the custom name
        searchTerms = searchTerms[1]
      } else {
        var traceName = searchTerms
      }
      // Get locus tag(s)
      if (searchTerms.includes(",")){
        searchTerms = searchTerms.split(",");
      } else {
        searchTerms = [searchTerms];
      }
      var X = []; // x value(s) of the matched data point(s)
      var Y = []; // y value(s) of the matched data point(s)
      var label = []; // locus_tag value(s) of the matched data point(s)
      // loop through all data points and see if the locus tag matches one in [searchTerms]
      for (j = 0; j < data.x.data[0].text.length; j += 1) {
        for (var k = 0; k < searchTerms.length; k++) {
          if (data.x.data[0].text[j].indexOf(searchTerms[k].trim()) !== -1) {
            // If searchTerms[k] is in the current gene\'s locus tag,
            // store the matched data point coordinates in the arrays
            X.push(data.x.data[0].x[j]);
            Y.push(data.x.data[0].y[j]);
            label.push(data.x.data[0].text[j]);
            break; // Stop searching further for this data point if a match is found
          }
        }
      }
      console.log(myDiv.data); // to log data structure
      // Add trace for the selected gene(s)
      Plotly.addTraces(myDiv,{
        x: X,
        y: Y,
        type: "scatter",
        mode: "markers",
        marker: {
          // pick color:
          "color": colors[myDiv.data.length-1],
          "size": 15,
          "line": {
            "color": "#424242",
            "width": 1
          }
        },
        text: label,
        name: traceName
      })
    }
    ;

    // Run performSearch if clicking on the search button
    document.getElementById("buttonSearch").addEventListener("click", performSearch);
    // Run performSearch if enter key is pressed
    document.getElementById("inputText").addEventListener("keypress", function(event) {
      if (event.key === "Enter") {
        performSearch();
      }
    }
    );'
    )))
  
  #save file in current directory:
  withr::with_dir('./', htmlwidgets::saveWidget(as_widget(p), file=sprintf("%s.html",sub("\n","",title))))
}
