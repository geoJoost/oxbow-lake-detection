# Geoscripting 2023
# Oxbow Gang:
  # Isabeau Verbrugge
  # Joost van Dalen
  # Nikolas Theofanous
  # Wessel van Leesten
  # Isaura Menezes de Oliveira Guido
# Identification of Oxbow Lakes in West-Papua, Indonesia

# This function detects lakes, excluding the river polygon

# Steps taken in the fuction:
# 1. Reproject to West Papua specific CRS
# 2. Cast the multipolygon features into single polygon features and remove duplicates
# 3. Remove objects that are smaller than 100 cells and further than 5000-meters buffer from the river, 
#    considered as noise.
# 4. Clean attribute table
# 5. Intersect the polygons within the buffer (lakes + river) with the river polygon
# 6. Remove polygons intersecting the river, therefore selecting only the lakes
# 7. Clean attribute table

# Load the required packages
library(sf)


detectLakes <- function(water_polygons, river_buffer) {
  
  # Reproject to a crs with unit in meters (Area: West Papua - ESPG:2310)
  multipolygons <- st_transform(multipolygons, 2310)
  
  # Cast the multipolygons to single polygons and create a new data frame
  polygons <- st_cast(multipolygons, "POLYGON")
  
  # Remove the duplicate polygons
  polygons <- polygons[!duplicated(polygons$id),]
  
  # Remove polygons that consist of less than 100 cells
  polygons <- polygons[polygons$count > 100, ]
  
  # Remove the polygons that are outside the buffer of the river
  polygons_within_buffer <- st_intersection(polygons, river_buffer)
  plot(polygons_within_buffer$geometry)
  
  # Delete unnecessary variables
  delete.list <- c('id.1','count.1', 'label.1')
  polygons_within_buffer <- polygons_within_buffer[,!(names(polygons_within_buffer) %in% delete.list)]
  
  # At this point, in polygons_within_buffer, the river polygon is still included
  # Use st_join (intersection) to join the remaining polygons (river included) to the river polygon 
  # (https://r-spatial.github.io/sf/reference/st_join.html)
  lakes_with_river <- st_join(polygons_within_buffer, river, join = st_intersects)
  plot(lakes_with_river$geometry)
  
  # Select only the water areas that are not the river 
  lakes <- lakes_with_river[is.na(lakes_with_river$id.y), ]

  # Remove unnecessary variables
  delete.list = c('id.y','level_0.y', 'level_1.y')
  polygons_within_buffer = polygons_within_buffer[,!(names(polygons_within_buffer) %in% delete.list)]
  
  # Plot lakes
  plot(lakes$geometry)
  
  # Return the lakes
  return(lakes)
}





