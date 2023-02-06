# Geoscripting 2023
# Oxbow Gang:
  # Isabeau Verbrugge
  # Joost van Dalen
  # Nikolas Theofanous
  # Wessel van Leesten
  # Isaura Menezes de Oliveira Guido
# Identification of Oxbow Lakes in West-Papua, Indonesia

# This script file estimates the shape of the water feature calculating the Circularity Index.

# Source for the Circularity Index: http://www.gaia-gis.it/gaia-sins/spatialite-sql-latest.html

# Explanation of the Circularity index: 
# it only applies to Polygons or MultiPolygons with the following interpretation:
#   1.0 corresponds to a perfectly circular shape.
#   very low values (near zero) correspond to a threadlike shape.
#   intermediate values correspond to a more or less flattened shape; 
#   lower index values means a stronger flattening effect.
# if the given Geometry does not contains any Polygon but contains at least a Linestring the index will always assume a 0.0 value.
# if the given Geometry only contains one or more Points the index will always assume a NULL value

# Steps taken in the function:
# 1. Creates the function to calculate the Circularity Index
# 2. Retrieves the area and perimeter for all the features and put them in new columns
# 3. Apply the circularityIndex function to the whole dataframe
# 4. Select the oxbow lakes: features with Circularity Index between 0.07 and 0.3 (values selected 
# based on visual interpretation)

###

# Install and open the necessary libraries
if(!"sf" %in% installed.packages()){install.packages("sf")}
if(!"lwgeom" %in% installed.packages()){install.packages("lwgeom")}
library(sf)
library(lwgeom)

calculateCircularityIndex <- function(water){

  # Create function to compute the circularity index
  circularityIndex = function(area, perimeter){
        
    # Formula to calculate the circularity index
    i <- ( 4 * pi * sum(area) ) / ( sum(perimeter) * sum(perimeter) )
    
    return(i)
    
  }

  
  # Compute area and perimeter
  water$area <- st_area(water)
  water$perimeter <- st_perimeter(water)
  
  # Apply the circularityIndex function to the dataset and store the results in a new column
  water$circIndex <- apply(X = water[, c("area", "perimeter")], MARGIN = 1, FUN = function(y) circularityIndex(y$area, y$perimeter))
  
  # Convert back to EPSG:4326 for visualization purposes and save dataset 
  water <- st_transform(water, 4326)
  
  return(water)
  
}