cat("\n#### Script 5 ####")
# Geoscripting 2023
# Oxbow Gang:
#              Isabeau Verbrugge
#              Joost van Dalen
#              Nikolas Theofanous
#              Wessel van Leesten
#              Isaura Menezes de Oliveira Guido
# Identification of Oxbow Lakes in West-Papua, Indonesia

# This script takes the following steps:
# 1. Open the files containing the oxbow lakes
# 2. Combine all oxbow lakes into one data frame
# 3. Create a proper date column into the combined data frame
#    a. A function is created that retrieves a string like 20180815
#    b. Split the string into different time units
#    c. Remove not useful variables from the data frame
#    d. Convert multipart polygons to singlepart
#    e. Dissolve polygons into each other to create one large polygon per oxbow lake
#    f. Remove unneeded variables to make the final result more readable
#    g. Save the output file as geojson

# Load required packages
library(ggplot2)
library(sf)
source("scripts/R/5-sup-mergeGeoJSONfiles.R")

# Run the function to retrieve a single file corresponding to oxbow lakes measured within the year
mergeGeoJSONfiles("output/oxbow_lakes/", "mergedOxbowLakes_byYear")

# Repeat the function for 'normal' lakes
mergeGeoJSONfiles("output/lakes/", "mergedLakes_byYear")