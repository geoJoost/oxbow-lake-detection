# Geoscripting 2023
# Oxbow Gang:
#              Isabeau Verbrugge
#              Joost van Dalen
#              Nikolas Theofanous
#              Wessel van Leesten
#              Isaura Menezes de Oliveira Guido
# Identification of Oxbow Lakes in West-Papua, Indonesia

# This script plots a static map showcasing all water bodies in western New Guinea, using the following steps:
# 1. Load GeoJSON files
# 2. For oxbow and 'normal' lakes, select only the data for the year chosen by the user
# 3. From Natural Earth, download data for the countries (Indonesia + Papua New Guinea) and clip this using a manually defined extent
# 4. Create a bounding box of the river which can be plotted on the overview map, together with NE Earth data
# 5. Create main map with data from the oxbow lakes, normal lakes, and the rivers
# 6. Add elements as legend, north arrow (not with ggspatial unfortunately :/ )
# 7. Merge both maps together using ggdraw()
# 8. And save to file


if(!"ggsn" %in% installed.packages()){install.packages("ggsn", dependencies = TRUE)}
if(!"rnaturalearth" %in% installed.packages()){install.packages("rnaturalearth")}
if(!"rnaturalearthdata" %in% installed.packages()){install.packages("rnaturalearthdata")}
if(!"grid" %in% installed.packages()){install.packages("grid")}
if(!"cowplot" %in% installed.packages()){install.packages("cowplot")}

library(ggplot2)
library(sf)
library(ggsn)
library(rnaturalearth)
library(rnaturalearthdata)
library(cowplot)
library(grid)

createStaticMap <- function(input_year) {
  # Read different GeoJSON files
  oxbowlakes_all <- st_read("output/mergedOxbowLakes_byYear.geojson", quiet=TRUE)
  lakes_all <- st_read("output/mergedLakes_byYear.geojson", quiet=TRUE)
  river <- st_read("data/riverArea.geojson", quiet=TRUE)
  
  # Select only the data for the user-selected year
  oxbowlakes <- oxbowlakes_all[oxbowlakes_all$year == input_year,]
  lakes <- lakes_all[lakes_all$year == input_year,]
  
  # Get bounding box of the river to use in the overview map
  bbox <- st_as_sfc(st_bbox(river))
  
  # Transform to local CRS for plotting and to prevent stretching
  oxbowlakes <- st_transform(oxbowlakes, crs = 2310)
  lakes <- st_transform(lakes, crs = 2310)
  river <- st_transform(river, crs = 2310)
  
  ######################
  #### Overview Map ####
  ######################
  
  # Create bounding box from bounding box website to use for overview map
  # Code from @TimSalabim at https://stackoverflow.com/questions/55050684/transform-result-of-st-bbox-to-other-crs
  viewarea <- st_as_sfc(st_bbox(c(
    xmin = 130.629883, xmax = 152.644043,
    ymin = -14.072645, ymax =  2.284551),
    crs = st_crs(4326)))
  
  # Load data for creating an overview map
  IndPng <- ne_countries(scale = "medium", returnclass = "sf",
                         country=c("Indonesia", "Papua New Guinea"))
  
  # Perform intersection to select the viewing area desired (approx island of New Guinea)
  papua <- st_intersection(IndPng, viewarea)
  
  overview_map <- ggplot(data = papua) +
    geom_sf() +
    # Manually set extents to get the area surrounding the island of New Guinea
    coord_sf(expand = FALSE) +
    
    # Plot bounding box as extent
    geom_sf(data = bbox, color='red') +
    
    # Basically set everything to blank in the background
    theme(panel.border = element_rect(color = 'black', fill=NA, linewidth=1), # Except this line which gives the entire plot a border
          panel.background = element_rect(fill='white'),
          plot.background = element_rect(fill='transparent', color=NA),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          axis.title.x = element_blank(), # Remove x-label
          axis.title.y = element_blank(), # Remove y-label
          axis.text.x=element_blank(),  #remove x axis labels
          axis.ticks.x=element_blank(), #remove x axis ticks
          axis.text.y=element_blank(),  #remove y axis labels
          axis.ticks.y=element_blank(),  #remove y axis ticks
    )
  
  ######################
  #### Main Map ####
  ######################
  
  main_map <- ggplot() +
    # First set the overall theme so it has a white background
    theme_bw() +
    
    # Plot the oxbow lakes
    # Code for plotting and legend is based on that written by @Gilles San Martin at https://stackoverflow.com/questions/48791741/add-multiple-legends-to-ggplot2-when-using-geom-sf
    geom_sf(data = oxbowlakes, aes(fill = "oxbow"), size=0, show.legend= "polygon") +
    
    # Plot normal lakes
    geom_sf(data = lakes, aes(fill = 'lake'), size=0, show.legend="polygon") +
    
    # Plot the river
    geom_sf(data = river, aes(fill = "riv"), size=0, show.legend = "polygon") +
    
    # Add colours + legend items for both geometries
    scale_fill_manual(values = c("oxbow" = "#FF0054", "lake" = "#023e8a", "riv" = "#00b4d8"), 
                      labels = c("Circular Lakes", "Oxbow Lakes", "Sungai Taritatu")
    ) +
    
    theme(legend.title = element_blank(), # Remove legend title
          axis.title.x = element_blank(), # Remove x-label
          axis.title.y = element_blank(), # Remove y-label
          legend.justification = c(0,1),  # Set legend within plot
          legend.position = c(.01, .25)   # Manually specify location of legend
    ) +
    
    # ggplot slightly expands the box and adds white space, make sure this does not happen
    coord_sf(expand = FALSE) +
    
    # Set north arrow, modified from https://rdrr.io/cran/ggsn/man/north.html 
    # We had an entire code for ggspatial but that can only be used if we update Rstudio
    # Functionality of this one is much less flexible compared to the other, hence the kind of odd looking north arrow + scale bar
    north(river, location = "topleft", symbol = 3) +
    # scale_fill_continuous(low = "#fff7ec", high = "#7F0000") # +
    
    scalebar(oxbowlakes, dist = 10, dist_unit = "km", 
             location = "bottomleft", st.bottom = FALSE, # Bit of a hack but outputs text above the scalebar
             st.size = 3, height = 0.01, border.size = 0.5, # Stylize the scalebar
             transform = FALSE, model = "WGS84") + # Standard options
    
    # Add title to plot
    ggtitle(paste0("Oxbow lakes in Western Guinea [", input_year, "]"))
  
  ######################
  #### Combined Map ####
  ######################
  
  # Combine both plots together
  insetmap <- ggdraw() +
    draw_plot(main_map) +
    draw_plot(overview_map, x = 0.49, y = 0.56, width = 0.5, height = 0.5)
  
  # And save as new file
  outputname = paste0("output/8-", input_year, "_insetmap.png")
  ggsave(filename = outputname, 
         plot = insetmap,
         width = 10, 
         height = 10,
         dpi = 300)
  
  # Print that the image has been saved
  print(paste0("The map of year ", input_year, " has been saved in the output directory"))
}

# Call the functin with input from bash
# Code from tdellhomme and mfoll at https://github.com/IARCbioinfo/R-tricks
createStaticMap(as.numeric(commandArgs(TRUE)[1]))