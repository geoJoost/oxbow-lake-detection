cat("\n#### Script 6 ####\n\n")
# Geoscripting 2023
# Oxbow Gang:
#   Isabeau Verbrugge
#   Joost van Dalen
#   Nikolas Theofanous
#   Wessel van Leesten
#   Isaura Menezes de Oliveira Guido
# Identification of Oxbow Lakes in West-Papua, Indonesia

# This script creates and save an interactive map as an html file where the user can pan and zoom in and out.
# It is possible to hover over the polygons and a label will pop up identifying if it is a Oxbow lake or 
# a ciruclar-shaped lake. The legend displays the color scheme that follows the years the images were taken,
# giving an idea of the changes occurred through time. 

if(!"leaflet" %in% installed.packages()){install.packages("leaflet")}
if(!"magrittr" %in% installed.packages()){install.packages("magrittr")}
if(!"htmlwidgets" %in% installed.packages()){install.packages("htmlwidgets")}

library(leaflet)
library(magrittr)
library(sf)
library(htmlwidgets)




# Open GEOJson files
oxbow_lakes <- st_read("output/mergedOxbowLakes_byYear.geojson", quiet=TRUE)
circular_lakes <- st_read("output/mergedLakes_byYear.geojson", quiet=TRUE)

# Creating the function to create the palette
pal <- colorFactor(colorRamp(c("#34207c", "#84206b", "#e55c30", "#f6d746"), interpolate = "spline"), oxbow_lakes$year)

# Initialize the leaflet map, add
m <- leaflet() %>%
  addProviderTiles("Esri.WorldTopoMap") %>% 
  setView( lng = 138.75, lat = -3.16, zoom = 10 ) %>% 
  
  # Add lake polygons (Oxbow and Circular lakes)
  addPolygons(data = oxbow_lakes, stroke = FALSE, smoothFactor = 0.3, 
              fillOpacity = 1, fillColor = ~pal(year), 
              label = "Oxbow lake", labelOptions = labelOptions(textsize = "15px"),
              group = "Oxbow Lakes") %>%
  
  addPolygons(data = circular_lakes, stroke = FALSE, smoothFactor = 0.3, 
              fillOpacity = 1, fillColor = ~pal(year), 
              label = "Circular lake", labelOptions = labelOptions(textsize = "15px"),
              group = "Circular Lakes") %>% 
  
  # Add the control widget to select which polygons to visualize
  # Based on code found here: https://r-graph-gallery.com/242-use-leaflet-control-widget.html
  addLayersControl(overlayGroups = c("Oxbow Lakes","Circular Lakes") , 
                   options = layersControlOptions(collapsed = FALSE)) %>% 
  
  # Add legend: colors represent the year 
  addLegend(pal = pal, values = oxbow_lakes$year, opacity = 1.0, title = "Year")


# save the widget in a html file if needed
saveWidget(m, file=paste0( getwd(), "/output/6-interactiveMap.html"))
print("Interactive map as .html saved in the output folder")




