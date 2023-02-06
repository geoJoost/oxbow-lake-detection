# Geoscripting 2023
# Oxbow Gang:
  # Isabeau Verbrugge
  # Joost van Dalen
  # Nikolas Theofanous
  # Wessel van Leesten
  # Isaura Menezes de Oliveira Guido
# Identification of Oxbow Lakes in West-Papua, Indonesia

# This script takes a class of water features and distinguishes oxbow lakes from circular-shaped lakes 
# based on their shape (estimated by the Circularity Index), excluding the river polygon 
# beforehand. (Explanation of the Circularity Index in the 4-sup-calculateCircularityIndex.R script)

# This script takes the following steps:
# 1. Open the file containing the river polygon
# 2. Unzip the directory containing the time-series files with the water polygons
# 3. Set the correct CRS for the river polygon
# 4. Create a buffer zone around the river polygon and remove the duplicate
# 5. within the for loop for each file:
#    a. Create an output names
#    b. Open the file
#    c. Remove river, selecting only lakes (function detectLakes)
#    d. Calculate the Circularity Index (function calculateCircularityIndex)
#    e. Select oxbow and circular-shaped lakes and write the two files in the output folder

cat("\n#### Script 4 ####\n\n")

  
library(sf)
source("scripts/R/4-sup-detectLakes.R")
source("scripts/R/4-sup-calculateCircularityIndex.R")

# create folder folders for Oxbow lakes and 'normal' lakes
if (!dir.exists("output/oxbow_lakes")) {
  dir.create("output/oxbow_lakes")
}

if (!dir.exists("output/lakes")) {
  dir.create("output/lakes")
}

# Read the file that contains the river polygon originated from the previous script
river <- st_read("data/riverArea.geojson", quiet=TRUE)

# Unzip time-series files to data directory. It contains one file with water polygons per year
unzip('data/earth_data_dates.zip', exdir = "data/unzipped_earth_data")

# List all GeoJSON files
water_files <- c(list.files("data/unzipped_earth_data", pattern = glob2rx('20*.geojson'), full.names = TRUE))

# Reproject CRS to EPSG:2310  (Area: West Papua - ESPG:2310, unit: meters)
river <- st_transform(river, 2310)
plot(river)
# Create a buffer around the river with a 5000-meter radius and remove the duplicates. 
#It will be used to select the water objects of interest and remove the further ones considered as noise.
river_buffer <- st_buffer(river, dist = 5000)
river_buffer <- river_buffer[!duplicated(river_buffer$id),]


for (geojson in water_files) {
  # Create an output name
  name <- unlist(strsplit(geojson, "[/.]+"))[3]
  oxbow_output_name <- paste0("output/oxbow_lakes/4-OxbowLakes_", name, ".geojson")
  circ_output_name <- paste0("output/lakes/4-CircularLakes_", name, ".geojson")

  # Print for error-handeling
  print(paste0("Starting on file with date ", name))
  
  # Read the GeoJSON file
  multipolygons <- st_read(geojson, quiet = TRUE)
  
  # Remove the river polygon and select only the lakes
  lakes <- detectLakes(multipolygons, river_buffer)
  
  # Compute Circularity Indexes per water feature
  lakes_circIndex <- calculateCircularityIndex(lakes)
  
  # Detect oxbow lakes from normal, circular-shaped lakes based on the Circularity Index
  # Select the oxbow lakes; values below 0.3 excludes almost all circular shaped lakes
  oxbow_lakes <- lakes_circIndex[(lakes_circIndex$circIndex > 0 & lakes_circIndex$circIndex < 0.3), ]
  plot(oxbow_lakes$geometry)
  
  #Select circular-shaped lakes: values above 0.3
  circ_lakes <- lakes_circIndex[(lakes_circIndex$circIndex > 0.3),]
  plot(circ_lakes$geometry)
  
  # Write the filtered polygon data to a new GeoJSON file
  st_write(oxbow_lakes, oxbow_output_name, delete_dsn = TRUE, delete_null_geometries = TRUE, quiet = TRUE)
  st_write(circ_lakes, circ_output_name, delete_dsn = TRUE, delete_null_geometries = TRUE, quiet = TRUE)
  
}

print("Identifying oxbow lakes process finished")
